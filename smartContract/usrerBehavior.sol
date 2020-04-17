pragma solidity >=0.4.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "./fileStruct.sol";
import "./Ownable.sol";
import "./safemath.sol";
import "./Token.sol";

contract userBehavior is FileStruct, Ownable {
    using SafeMath for uint256;
    event Log_uploadData(address owner, Kind kind, uint idFile);
    event Log_downloadFile(address recipient, uint idFile);
    event Log_signUsingDataContract(uint idFile,address owner, address signer);
    event Log_cancelContract(uint id, address canceler);
    event Log_createSurveySuccessfully(address owner, uint idSurvey);
    event Log_takenSurveySuccessfully(address people, uint idSurvey);
    event Log_sharingIndividualData(address indexed owner);
    event Log_withdraw(address recipient, uint amount);

    Token token;

    uint idFile = 0;
    uint idSurvey = 0;
    uint idContract = 0;
    uint pDMoney;
    Feedback[] public _feedback;
    individualData[] public PData;
    File[] public FileList;
    user[]  unvalidUser;
    mapping(uint => File) files;
    mapping(address => user) UserList;
    mapping(uint => Survey) survey;
    mapping(uint => usingDataContract[]) usingDataContractOfAData;
    mapping(uint => usingDataContract) usingdatacontract;
    mapping (string=>usingDataContract) usingDataContractList;

    modifier isValidFile(uint _idFile) {
        require(files[_idFile].valid,"File haven't validated yet !");
        _;
    }
    modifier isValidUser(){
        require(UserList[msg.sender].isValid,"User haven't actived");
        _;
    }

    function setTokenAddress(address _token) public onlyOwner isValidUser {
        token = Token(_token);
    }

    function setDataSharingCommision(uint _pDMoney) public onlyOwner isValidUser {
        pDMoney = _pDMoney;
    }
    // Upload data
    function uploadData(
        string memory _fileHash,
        uint _price,
        Kind _kind,
        string memory _idMongoose
        ) public isValidUser() returns(uint) {
        idFile++;


        File memory tempFile = File(idFile,_idMongoose,_fileHash,msg.sender,_price,0,0,now,false,_kind,0);
        FileList.push(tempFile);
        UserList[msg.sender].uploadList.push(tempFile.idFile);
        files[idFile] = tempFile;
        emit Log_uploadData(msg.sender,_kind,idFile);
        return idFile;
    }

    // Using data
    function downloadData(uint _idFile) public isValidFile(_idFile) isValidUser returns(string memory) {
        require(files[_idFile].valid,"File haven't ready to download !");
        usingDataContract[] memory result;
        for (uint i = 0; i < usingDataContractOfAData[_idFile].length; i++) {
            if(usingDataContractOfAData[_idFile][i].signer == msg.sender && usingDataContractOfAData[_idFile][i].timeExpired > now){
                result[i] = usingDataContractOfAData[_idFile][i];
            }
        }
        if (result.length == 0) {
            token.TransferFromTo(msg.sender, address(this),files[_idFile].price);
            token.TransferFromTo(address(this), files[_idFile].owner, files[_idFile].price.mul(90).div(100));
        }
        UserList[msg.sender].usedList.push(_idFile);
        files[_idFile].totalUsed = files[_idFile].totalUsed.add(1);
        files[_idFile].weekUsed = files[_idFile].weekUsed.add(1);
        emit Log_downloadFile(msg.sender, _idFile);
        return files[_idFile].fileHash;
    }

    //Get owner of data
    function getUserUpload(uint _idFile) public view isValidUser returns(address) {
        return files[_idFile].owner;
    }

    //Get file by idFile
    function getFileById(uint _idFile) public view isValidUser  returns(File memory) {
        return files[_idFile];
    }

    // Create contract
    function createContract(
        uint _idFile,
        string memory _idContractMongo,
        string memory _dataHash,
        string memory _contentHash,
        uint _contractMoney,
        address _owner,
        uint _ownerCompensationAmount,
        address _signer,
        uint _signerCompensationAmount,
        uint _timeExpired
    ) public isValidUser() {
        require(msg.sender == _owner || msg.sender == _signer,"Check owner or signer !");
        require(_owner == files[_idFile].owner,"Check owner of data !");
        bool _ownerApproved;
        bool _signerApproved;
        if(msg.sender == _owner){
            _ownerApproved = true;
            _signerApproved = false;
        }
        if(msg.sender == _signer){
            _ownerApproved = false;
            _signerApproved = true;
        }
        usingDataContract memory tempContract = usingDataContract(
            0,
            _idFile,
            _dataHash,
            _contentHash,
            _contractMoney,
            _owner,
            _ownerCompensationAmount,
            _ownerApproved,
            _signer,
            _signerCompensationAmount,
            _signerApproved,
            now.add(_timeExpired),
            false
        );
        usingDataContractList[_idContractMongo] = tempContract;
    }

    //Thoả thuận giữa 2 người
    function setApproved(string memory _idContractMongo) public isValidUser {
        require(usingDataContractList[_idContractMongo].timeExpired > now,"This contract is expired!");
        require(msg.sender == usingDataContractList[_idContractMongo].signer &&
        usingDataContractList[_idContractMongo].signerApproved == false || msg.sender == usingDataContractList[_idContractMongo].owner && usingDataContractList[_idContractMongo].ownerApproved == false,
        "the Error about signer or owner address!");
        if(msg.sender == usingDataContractList[_idContractMongo].signer){
            usingDataContractList[_idContractMongo].signerApproved = true;
        }
        if(msg.sender == usingDataContractList[_idContractMongo].owner){
            usingDataContractList[_idContractMongo].ownerApproved = true;
        }
        token.TransferFromTo(usingDataContractList[_idContractMongo].signer,
        address(this),usingDataContractList[_idContractMongo].contractMoney);
        token.TransferFromTo(address(this),
        files[usingDataContractList[_idContractMongo].idFile].owner,
        usingDataContractList[_idContractMongo].contractMoney.mul(90).div(100));
        usingDataContract memory mainContract = usingDataContract(
            idContract.add(1),
            usingDataContractList[_idContractMongo].idFile,
            usingDataContractList[_idContractMongo].dataHash,
            usingDataContractList[_idContractMongo].contentHash,
            usingDataContractList[_idContractMongo].contractMoney,
            usingDataContractList[_idContractMongo].owner,
            usingDataContractList[_idContractMongo].ownerCompensationAmount,
            usingDataContractList[_idContractMongo].ownerApproved,
            usingDataContractList[_idContractMongo].signer,
            usingDataContractList[_idContractMongo].signerCompensationAmount,
            usingDataContractList[_idContractMongo].signerApproved,
            usingDataContractList[_idContractMongo].timeExpired,
            usingDataContractList[_idContractMongo].isCancel
        );
        usingDataContractOfAData[idFile].push(mainContract);
        usingdatacontract[mainContract.id] = mainContract;
        emit Log_signUsingDataContract(idFile, mainContract.owner, mainContract.signer);
    }

    // Huỷ hợp đồng
    function cancelContract(uint _idFile) public isValidUser {
       // require(usingdatacontract[_idFile],"This contract not exist!");
        require(usingdatacontract[_idFile].isCancel == false && usingdatacontract[_idFile].timeExpired > now,
        "This contract has canceled already!");
        require(msg.sender == usingdatacontract[_idFile].signer || msg.sender == usingdatacontract[_idFile].owner,
        "You don't have this privilege");
        if(msg.sender == usingdatacontract[_idFile].owner){
            token.TransferFromTo(usingdatacontract[_idFile].owner,usingdatacontract[_idFile].signer, usingdatacontract[_idFile].ownerCompensationAmount);
        }
        if(msg.sender == usingdatacontract[_idFile].signer){
            token.TransferFromTo(usingdatacontract[_idFile].signer,usingdatacontract[_idFile].owner, usingdatacontract[_idFile].signerCompensationAmount);
        }
        usingdatacontract[_idFile].isCancel = true;
        emit Log_cancelContract(usingdatacontract[_idFile].id, msg.sender);
    }

    // Get using data contract
    function getUsingDataContract(uint _idFile) public view isValidUser returns(usingDataContract memory) {
        return usingdatacontract[_idFile];
    }

    // Get owner of using data contract
    function getOwnerContract(uint _idFile) public view isValidUser returns(address){
        return usingdatacontract[_idFile].owner;
    }

    //Get signer of using data contract
    function getSignerContract( uint _idFile) public view isValidUser returns(address){
        return usingdatacontract[_idFile].signer;
    }

    //Get total contract of a file
    function getContractPerFile(uint _idFile) public view isValidUser returns(usingDataContract[] memory) {
        return usingDataContractOfAData[_idFile];
    }
    // Create survey to collect infomation
    function createSurvey(
        string memory _idMongoose,
        string memory _contentHash,
        uint _endDay,
        uint _feePerASurvey,
        uint _surveyInDemand// the number of survey need to take
    ) public isValidUser  {
        token.TransferFromTo(msg.sender, address(this), _feePerASurvey.mul(_surveyInDemand));
        idSurvey = idSurvey.add(1);
        Survey memory surveys = Survey(
            idSurvey,
            msg.sender,
            _idMongoose,
            _contentHash,
            now,
            now + _endDay,
            _feePerASurvey,
            _surveyInDemand,
            0
        );
        survey[idSurvey] = surveys;
        UserList[msg.sender].surveyCreated = UserList[msg.sender].surveyCreated.add(1);
        emit Log_createSurveySuccessfully(msg.sender, idSurvey);
    }

    //withdraw excess money from a survey
    function withdrawExcessFromSurvey(uint _idSurvey) public isValidUser {
        require(survey[_idSurvey].endDate < now,"Survey is still in process!");
        require(msg.sender == survey[_idSurvey].owner,"You aren't owner!");
        uint _excessMoney = (survey[_idSurvey].feePerASurvey.mul(survey[_idSurvey].surveyInDemand)).sub(survey[_idSurvey].feePerASurvey.mul(survey[_idSurvey].participatedPeople));
        token.TransferFromTo(address(this), msg.sender, _excessMoney);
    }

    //take Survey
    function takeSurvey(uint _idSurvey) public isValidUser {
        require(survey[_idSurvey].endDate > now,"Survey is expired!");
        require(survey[_idSurvey].surveyInDemand < survey[_idSurvey].participatedPeople,"This survey is enough people!");
        survey[_idSurvey].participatedPeople = survey[_idSurvey].participatedPeople.add(1);
        UserList[msg.sender].activity = UserList[msg.sender].activity.add(1);
        token.TransferFromTo(address(this), msg.sender, survey[_idSurvey].feePerASurvey);

        emit Log_takenSurveySuccessfully(msg.sender, _idSurvey);
    }

    // Update latest ranking
    function getRanking() public view isValidUser returns(dataRanking[] memory) {
        dataRanking[] memory result;//= new dataRanking[](FileList.length);
        for (uint i = 0; i < FileList.length; i++){
            result[i] = dataRanking(FileList[i].idFile, FileList[i].totalUsed);
        }
        for (uint i = 0; i < result.length - 1 ; i++) {
            uint totalused = result[i].downloaded;
            for (uint j = i + 1; j < result.length ; j++) {
                if (result[j].downloaded > totalused) {
                    totalused = result[j].downloaded;
                    dataRanking memory temp = result[i];
                    result[i] = result[j];
                    result[j] = temp;
                }
            }
        }
        return result;
        }

    // import personal information
    function setPersonalInformation(
        uint _idIdentity,
        string memory _name,
        uint _DoB,
        uint _male,
        string memory _hobbies,
        string memory _addressLive,
        bool _isMarried,
        uint _phone,
        bool _shared
    ) public isValidUser {
        individualData memory _pIf = individualData(
            msg.sender,
            _idIdentity,
            _name,
            _DoB,
            _male,
            _hobbies,
            _addressLive,
            _isMarried,
            _phone,
            _shared
        );
        if(_pIf.shared == true){
            token.TransferFromTo(address(this),msg.sender,pDMoney);
        }
        UserList[msg.sender].personalData = _pIf;
    }

    // get publish information
    function getPersonalInformation() public isValidUser returns(individualData[] memory) {
        token.TransferFromTo(msg.sender,address(this),PData.length.mul(pDMoney));
        return PData;
    }

    // share personal information
    function publishInformation() public isValidUser {
        //require(msg.sender = UserList[msg.sender].ownerAddress,"this account is not set up");
        require(UserList[msg.sender].personalData.shared = false,"Your personal data is publish!");
        UserList[msg.sender].personalData.shared = true;
        PData.push(UserList[msg.sender].personalData);
        token.TransferFromTo(address(this),msg.sender,pDMoney);
        emit Log_sharingIndividualData(msg.sender);
    }

    // create user
    /** 
        * @dev this function is to use in backend, when user start system, call this function immediately
    */
    function createUser() public {
        //require(!UserList[msg.sender],"this address has had account!");
        uint[] memory _uploadList;
        uint[] memory _downloadList;
        individualData memory Pdt;
        user memory User = user(
            msg.sender,
            _uploadList,
            _downloadList,
            false,
            0,
            0,
            0,
            Pdt
        );
        unvalidUser.push(User);
        UserList[msg.sender] = User;
    }

    function ValidateUser() public onlyOwner {
        
    }
}

// set lại cho một mảng là rỗng
// set validality of user
// set hợp lệ file
// 1 HAK đổi ra ether chỗ nào