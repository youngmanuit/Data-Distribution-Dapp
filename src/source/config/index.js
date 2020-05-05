var path = require('path');
const ethers = require('ethers');
const abi = require ('./abi');
const root = path.normalize(__dirname + '/..');
const env = process.env.ENV || "staging"; // u can use local or online. let change it "local or staging"

var main_config = {
    //this
    env: env,
            host: '0.0.0.0',
            port: 6969,

            secret: '38400c22123166d068303d717dbdddd8a4de8c16e6b6e8efe3fd5bf6364ec929', //JWT
            ownerSecretKey: '63B3B3D1E9F089A1333066BF4E4832EC48FCBC3720FDECA1930D27AC48965983',
            provider: ethers.getDefaultProvider('kovan'),

            userBehaviorAddress: '0x549D12f51b1Cbeae5bF054D940fAdc97b81FBc6a',
            userBehaviorABI: abi.userBehaviorABI,

            tokenAddress: '0xB8c490964145434C9d0B336763d6F790F06d96A9',
            tokenABI: abi.tokenABI,
            
            root_dir: root,
            models_dir: root + '/models',
            controllers_dir: root + '/controllers',
            library_dir: root + '/library',
            web_dir: root + '/web',
}

module.exports = Object.assign(main_config, require('./env/'+env) || {});