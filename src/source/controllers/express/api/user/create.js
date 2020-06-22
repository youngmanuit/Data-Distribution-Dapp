const config = require('../../../../config');
const lib_password = require(config.library_dir + '/password');
const response_express = require(config.library_dir + '/response').response_express;
const User = require(config.models_dir + '/mongo/user');
const lib_common = require(config.library_dir+'/common');
const sha256 = require('sha256')
const ethers = require('ethers');

module.exports = (req, res) => {
    let miss = lib_common.checkMissParams(res, req.body, ["user"])
    if (miss){
        console.log("Miss param at Create");
        return;
    }
    let missField = lib_common.checkMissParams(res, req.body.user, ["email", "password", "phone", "nickName", "genre"])
    if (missField){
        console.log("Miss param at Create Field");
        return;
    } 

    lib_password.cryptPassword(req.body.user.password)
    .then(passwordHash => {
        delete req.body.user.password;
        req.body.user.password_hash = passwordHash;
        req.body.user.privateKey = sha256(config.secret + req.body.user.email)
        let wallet = new ethers.Wallet(req.body.user.privateKey)
        req.body.user.addressEthereum = wallet.address
        console.log(req.body.user)

        let wallet2 = new ethers.Wallet(config.ownerSecretKey , config.provider);
        let contractWithSigner = new ethers.Contract(config.userBehaviorAddress, config.userBehaviorABI, wallet2)
        
        contractWithSigner.createUser(req.body.user.addressEthereum)
        .then(async tx => {
            if(!tx){
                return response_express.exception(res, "Transaction failed, please try again!")
            }
            console.log(tx)
            const receipt = await tx.wait()
            if(receipt.status !== 1){
                return response_express.exception(res, "Receipt not exist!");
            }
            console.log(receipt)
            User.updateOne({ privateKey: config.ownerSecretKey }, { $push: { validateUser: req.body.user.addressEthereum } }).exec()
        })
        .catch(err => {
            console.log(err)
            response_express.exception(res, JSON.parse(err.responseText).error.message || err)
        });
        return User.create(req.body.user);
    })
    .then(() => {
        response_express.success(res);
    })
    .catch(err => {
        response_express.exception(res, err);
    })
}