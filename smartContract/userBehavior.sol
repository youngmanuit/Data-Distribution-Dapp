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
    event Log_takenFeedbackSuccessfully(uint idFile);
    event Log_sharingIndividualData(address indexed owner);
    event Log_withdraw(address recipient, uint amount);
    event huntEventSuccessfully(address indexed _peopleInNeed, address indexed _hunter);

    Token token;

    uint idFile = 0;
    uint idSurvey = 0;
    uint idContract = 0;
    uint pDMoney = 0;
    uint idHuntfile;
    individualData[] PData;
    File[]  FileList;
    huntedFile[] huntedfiles;
    UnlabelFile[] unlabelfiles;
    mapping(uint => File) files;
    mapping(address => user) UserList;
    mapping(uint => Survey) survey;
    mapping(uint => usingDataContract[]) usingDataContractOfAData;
    mapping(uint => usingDataContract) usingdatacontract;
    mapping(string => usingDataContract) usingDataContractList;
    mapping(uint => Feedback[]) feedback;
    mapping(uint => huntedFile) huntedfile;
    mapping(uint => UnlabelFile) unlabelfile;

    modifier isValidFile(uint _idFile) {
        require(files[_idFile].valid,"File haven't validated yet !");
        _;
    }
    modifier isValidUser(){
        require(UserList[msg.sender].isValid,"User haven't actived");
        _;
    }
    
    //Set địa chỉ Token

    function setTokenAddress(address _token) public onlyOwner {
        token = Token(_token);
    }
    
    // Set amount money user will receive when sharing personal data 
    function setDataSharingCommision(uint _pDMoney) public onlyOwner {
        pDMoney = _pDMoney;
    }
    // Upload data
    function uploadData(
        string memory _fileHash,
        uint _price,
        Kind _kind,
        string memory _idMongoose
        ) public isValidUser returns(uint) {
        idFile = idFile.add(1);

        File memory tempFile = File(idFile,_idMongoose,_fileHash,msg.sender,_price,0,0,now,false,_kind,0);
        FileList.push(tempFile);
        UserList[msg.sender].uploadList.push(tempFile.idFile);
        files[idFile] = tempFile;
        emit Log_uploadData(msg.sender,_kind,idFile);
        return idFile;
    }
    function getLengh(uint _idFile) public view returns(uint){
        return usingDataContractOfAData[_idFile].length;
    }
    

    // Using data
    function downloadData(uint _idFile) public isValidFile(_idFile) isValidUser returns(string memory) {
        bool hasContract = false;
        bool isHuntedFile = false;
        for (uint i = 0; i < usingDataContractOfAData[_idFile].length; i++) {
            if(usingDataContractOfAData[_idFile][i].signer == msg.sender && usingDataContractOfAData[_idFile][i].timeExpired > now){
                hasContract = true;
                break;
            }
        }
        for (uint i = 0; i < huntedfiles.length; i++) {
            if(huntedfiles[i].peopleInNeed == msg.sender && huntedfiles[i].isHunted == true){
                isHuntedFile = true;
                break;
            }
        }
        
        if (hasContract == false && isHuntedFile == false) {
            token.TransferFromTo(msg.sender, address(this),files[_idFile].price);
            token.TransferFromTo(address(this), files[_idFile].owner, files[_idFile].price);
        }
        UserList[msg.sender].usedList.push(_idFile);
        files[_idFile].totalUsed = files[_idFile].totalUsed.add(1);
        files[_idFile].weekUsed = files[_idFile].weekUsed.add(1);
        emit Log_downloadFile(msg.sender, _idFile);
        return files[_idFile].fileHash;
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
    ) public isValidUser isValidFile(_idFile) {
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
        idContract = idContract.add(1);
        usingDataContract memory mainContract = usingDataContract(
            idContract,
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
    function cancelContract(uint _idContract) public isValidUser {
       // require(usingdatacontract[_idContract],"This contract not exist!");
        require(usingdatacontract[_idContract].isCancel == false && usingdatacontract[_idContract].timeExpired > now,
        "This contract has canceled already!");
        require(msg.sender == usingdatacontract[_idContract].signer || msg.sender == usingdatacontract[_idContract].owner,
        "You don't have this privilege");
        if(msg.sender == usingdatacontract[_idContract].owner){
            token.TransferFromTo(usingdatacontract[_idContract].owner,usingdatacontract[_idContract].signer, usingdatacontract[_idContract].ownerCompensationAmount);
        }
        if(msg.sender == usingdatacontract[_idContract].signer){
            token.TransferFromTo(usingdatacontract[_idContract].signer,usingdatacontract[_idContract].owner, usingdatacontract[_idContract].signerCompensationAmount);
        }
        usingdatacontract[_idContract].isCancel = true;
        emit Log_cancelContract(usingdatacontract[_idContract].id, msg.sender);
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
        require(survey[_idSurvey].surveyInDemand > survey[_idSurvey].participatedPeople,"This survey is enough people!");
        survey[_idSurvey].participatedPeople = survey[_idSurvey].participatedPeople.add(1);
        UserList[msg.sender].activity = UserList[msg.sender].activity.add(1);
        
        token.TransferFromTo(address(this), msg.sender, survey[_idSurvey].feePerASurvey);

        emit Log_takenSurveySuccessfully(msg.sender, _idSurvey);
    }
    
    // take Feedback
    function takeFeedback(string memory _idMongo, uint _idFile) public isValidUser {
        bool hasFile;
        for(uint i =0; i < UserList[msg.sender].usedList.length; i++){
            if(_idFile == UserList[msg.sender].usedList[i]){
                hasFile = true;
                break;
            }
        }
        require(hasFile,'You have not used this data');
        Feedback memory _fb = Feedback(
            msg.sender,
            _idMongo,
            _idFile
        );
        feedback[_idFile].push(_fb);
        emit Log_takenFeedbackSuccessfully(_idFile);
    }
    
    // getFeedback
    function getFeedback(uint _idFile) public view isValidUser returns(string[] memory) {
        string[] memory hashMongo = new string[](feedback[_idFile].length);
        for(uint i =0;i< feedback[_idFile].length;i++){
            hashMongo[i] = feedback[_idFile][i].idMongo;
        }
        return hashMongo;
    }
    
    // Update latest ranking
    function getRanking() public view isValidUser returns(dataRanking[] memory) {
        dataRanking[] memory result = new dataRanking[](FileList.length);
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
    
    //Post huntFile to find data 
    function postHuntFile(string memory _characteristicHash, uint _fee) public isValidUser{
        idHuntfile.add(1);
        huntedFile memory _hf = huntedFile(
            idHuntfile,
            0,
            msg.sender,
            _characteristicHash,
            address(0),
            _fee,
            false
        );
        huntedfiles.push(_hf);
        huntedfile[idHuntfile] = _hf;
    }
    
    function getHuntFile() public view isValidUser returns(huntedFile[] memory){
        return huntedfiles;
    }
    
    function hunt(uint _idHuntFile, uint _idHuntedFile) public isValidFile(_idHuntedFile) isValidUser{
        require(huntedfile[_idHuntFile].isHunted == false, "File is no longer need ");
        require(files[_idHuntedFile].owner == msg.sender,"You are not owner of this file!");
        huntedfile[_idHuntFile].idhuntedFile = _idHuntedFile;
        huntedfile[_idHuntFile].hunter = msg.sender;
    }
    
    function approveHuntedFile(uint _idHuntFile) public isValidUser{
        require(huntedfile[_idHuntFile].peopleInNeed == msg.sender,"You have no right to approve!");
        require(huntedfile[_idHuntFile].idhuntedFile != 0);
        huntedfile[_idHuntFile].isHunted = true;
        token.TransferFromTo(huntedfile[_idHuntFile].peopleInNeed, huntedfile[_idHuntFile].hunter, huntedfile[_idHuntFile].fee);
        emit huntEventSuccessfully(huntedfile[_idHuntFile].peopleInNeed, huntedfile[_idHuntFile].hunter);
    }
        

    // import personal information
    function setPersonalInformation(
        string memory _dataHash,
        bool _shared
    ) public isValidUser {
        require(pDMoney != 0,"The commision is not set");
        individualData memory _pIf = individualData(
            msg.sender,
            _dataHash,
            _shared
        );
        if(_pIf.shared == true){
            token.TransferFromTo(address(this),msg.sender,pDMoney);
        }
        UserList[msg.sender].personalData = _pIf;
    }

    // get publish information
    function getPersonalInformation() public isValidUser returns(individualData[] memory) {
        require(PData.length > 0,"No data is published");
        require(pDMoney != 0,"The commision is not set");
        token.TransferFromTo(msg.sender,address(this),PData.length.mul(pDMoney));
        return PData;
    }

    // share personal information
    function publishInformation() public isValidUser {
        require(UserList[msg.sender].personalData.owner == msg.sender,"this account is not set up");
        require(UserList[msg.sender].personalData.shared == false,"Your personal data is publish!");
        UserList[msg.sender].personalData.shared = true;
        PData.push(UserList[msg.sender].personalData);
        token.TransferFromTo(address(this),msg.sender,pDMoney);
        emit Log_sharingIndividualData(msg.sender);
    }
    
    // Find people lable data
    function FindLabler(uint _idFile, uint _wage) public isValidUser {
        bool hasContract = false;
        bool isDownloaded = false;
        for (uint i = 0; i < usingDataContractOfAData[_idFile].length; i++) {
            if(usingDataContractOfAData[_idFile][i].signer == msg.sender && usingDataContractOfAData[_idFile][i].timeExpired > now){
                hasContract = true;
                break;
            }
        }
        
        for(uint i=0; i < UserList[msg.sender].usedList.length; i++){
            if(UserList[msg.sender].usedList[i] == _idFile){
                isDownloaded = true;
                break;
            }
        }
        require(msg.sender == files[_idFile].owner || hasContract == true || isDownloaded == true);
        UnlabelFile memory _uf = UnlabelFile(
            _idFile,
            "",
            _wage,
            msg.sender,
            address(0),
            false,
            false
        );
        unlabelfiles.push(_uf);
        unlabelfile[idFile]=_uf;
    }
    function getUnlableFile() public view isValidUser returns(UnlabelFile[] memory){
        return unlabelfiles;
    }
    
    function Labeling(uint _idUnlabelFile, string memory _hashFile) public isValidUser{
        require(unlabelfile[_idUnlabelFile].isLabeled == false || unlabelfile[_idUnlabelFile].locked == false, "File is no longer need label");
        unlabelfile[_idUnlabelFile].implementer = msg.sender;
        unlabelfile[_idUnlabelFile].hashLabeledFile = _hashFile;
        unlabelfile[_idUnlabelFile].locked = true;
    }
    
    function approveLabeledFile(uint _idUnlabelFile) public isValidUser returns(string memory){
        require(unlabelfile[_idUnlabelFile].renter == msg.sender,"You have no right to approve!");
        require(unlabelfile[_idUnlabelFile].locked = true,"Haven't labeled yet!");
        unlabelfile[_idUnlabelFile].isLabeled = true;
        token.TransferFromTo(unlabelfile[_idUnlabelFile].renter, unlabelfile[_idUnlabelFile].implementer, unlabelfile[_idUnlabelFile].wage);
        return unlabelfile[_idUnlabelFile].hashLabeledFile;
    }

    
    /**
     * view function
    */
    function get() public view isValidUser returns(address, bool){
        return (UserList[msg.sender].personalData.owner,UserList[msg.sender].personalData.shared);
    }
    //Get owner of data
    function getUserUpload(uint _idFile) public view isValidUser returns(address) {
        return files[_idFile].owner;
    }

    //Get file by idFile
    function getFileById(uint _idFile) public view isValidUser  returns(string memory,File memory, bool) {
        return (files[_idFile].idMongoose,files[_idFile],files[_idFile].valid) ;
    }

    // Get using data contract
    function getUsingDataContract(uint _idcontract) public view isValidUser returns(usingDataContract memory) {
        return usingdatacontract[_idcontract];
    }

    // Get owner of using data contract
    function getOwnerContract(uint _idcontract) public view isValidUser returns(address){
        return usingdatacontract[_idcontract].owner;
    }

    //Get signer of using data contract
    function getSignerContract( uint _idFile) public view isValidUser returns(address){
        return usingdatacontract[_idFile].signer;
    }

    //Get total contract of a file
    function getContractPerFile(uint _idFile) public view isValidUser returns(uint) {
        return usingDataContractOfAData[_idFile].length;
    }
    
    // create user
    /** 
        * @dev this function is to use in backend, when user start system, call this function immediately
    */
    function createUser() public {
        require(UserList[msg.sender].ownerAddress == 0x0000000000000000000000000000000000000000,"this address has had account!");
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
        UserList[msg.sender] = User;
    }

    function validateUser(address _addressUserToValidate) public onlyOwner {
        require(UserList[_addressUserToValidate].ownerAddress != 0x0000000000000000000000000000000000000000,"this address hasn't created!");
        require(UserList[_addressUserToValidate].isValid == false, "This account has already validated ");
        UserList[_addressUserToValidate].isValid = true;
    }
    
    function validateFile(uint _idFile) public onlyOwner {
        require(files[_idFile].owner != 0x0000000000000000000000000000000000000000,"This file is not exist");
        require(files[_idFile].valid == false, "This file has already validated");
        files[_idFile].valid = true;
    }
    function getUserlist() public view returns(address, bool){
        return (UserList[msg.sender].ownerAddress, UserList[msg.sender].isValid);
    }
}

// set lại cho một mảng là rỗng
// set validality of user
// set hợp lệ file
// 1 HAK đổi ra ether chỗ nào