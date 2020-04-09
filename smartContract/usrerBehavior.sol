pragma solidity >=0.4.0 <0.7.0;
import "./fileStruct.sol";
import "./Ownable.sol";
import "./safemath.sol";

contract userBehavior is FileStruct, Ownable {
    using SafeMath for uint256;
    event Log_uploadData(address owner, Kind kind, uint idFile);
    event Log_downloadFile(address recipient, uint idFile);
    event Log_signUsingDataContract(uint idFile,address owner, address signer);
    event Log_cancelContract(uint id, address canceler);
    event Log_takeFeedback(address ownerFeedback, uint idFile);
    event Log_createSurvey(address owner, uint idSurvey);
    event Log_sharingIndividualData(address indexed owner);
    event Log_withdraw(address recipient, uint amount);

    uint idFile = 0;
    uint idSurvey = 0;
    uint idContract = 0;
    Feedback[] public _feedback;
    //mapping(address=>File[]) FileList;
    mapping(uint => File) files;
    mapping(address => User) UserList;
    mapping(uint => Survey) survey;
    mapping(uint => usingDataContract[]) usingDataContractOfAUser;
    mapping (string=>usingDataContract) usingDataContractList;

    modifier isValidFile(uint _idFile) {
        require(files[_idFile].valid,"File haven't validated yet !");
        _;
    }
    modifier isValidUser(address _user){
        require(UserList[_user].isValid,"User haven't actived");
        _;
    }
    // Upload data
    function uploadData(string memory _fileHash, uint _price, Kind _kind, string memory _idMongoose) public isValidUser(msg.sender) returns(uint) {
        idFile++;


        File memory tempFile = File(idFile,_idMongoose,_fileHash,msg.sender,_price,0,0,now,false,_kind,0);
        //Filelist[msg.sender].push(tempFile);
        UserList[msg.sender].uploadList.push(tempFile);
        files[idFile] = tempFile;
        emit Log_uploadData(msg.sender,_kind,idFile);
        return idFile;
    }

    // Using data
    function downloadData(uint _idFile) public isValidFile(_idFile) isValidUser(msg.sender) payable returns(string memory) {
        require(files[_idFile].valid,"File haven't ready to download !");
        require(msg.value > files[_idFile].price,"You haven't tranfer enough moneys!");
        files[_idFile].owner.transfer(files[_idFile].price.mul(0.8));
        UserList[msg.sender].usedList.push(_idFile);
        files[_idFile].totalUsed = files[_idFile].totalUsed.add(1);
        files[_idFile].weekUsed = files[_idFile].weekUsed.add(1);
        
        emit Log_downloadFile(msg.sender, _idFile);
        return files[_idFile].fileHash;
    }

    //Get owner of data
    function getUserUpload(uint _idFile) public view isValidUser(msg.sender) returns(user memory) {
        return files[_idFile].owner;
    }

    //Get file by idFile
    function getFileById(uint _idFile) public view isValidUser(msg.sender)  returns(File memory) {
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
    ) public isValidUser(msg.sender) {
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
    function setApproved(string memory _idContractMongo) public isValidUser(msg.sender) payable {
        require(usingDataContractList[_idContractMongo].timeExpired > now,"This contract is expired!");
        require(msg.sender == usingDataContractList[_idContractMongo].signer && usingDataContractList[_idContractMongo].signerApproved == false
        || msg.sender == usingDataContractList[_idContractMongo].owner && usingDataContractList[_idContractMongo].ownerApproved == false,
        "the Error about signer or owner address!");
        if(msg.sender == usingDataContractList[_idContractMongo].signer){
            require(msg.sender.balance > usingDataContractList[_idContractMongo].contractMoney.add(usingDataContractList[_idContractMongo].signerCompensationAmount),
            "You are not eligible!");
            require(msg.value = usingDataContractList[_idContractMongo].contractMoney.add(usingDataContractList[_idContractMongo].signerCompensationAmount));
            files[usingDataContractList[_idContractMongo].idFile].owner.transfer(usingDataContractList[_idContractMongo].contractMoney.mul(0.9));
            usingDataContractList[_idContractMongo].signerApproved = true;
        }
        if(msg.sender == usingDataContractList[_idContractMongo].owner){
            require(msg.sender.balance > usingDataContractList[_idContractMongo].ownerCompensationAmount,
            "You are not eligible!");
            require(msg.value = usingDataContractList[_idContractMongo].ownerCompensationAmount);
            files[usingDataContractList[_idContractMongo].idFile].owner.transfer(usingDataContractList[_idContractMongo].contractMoney.mul(0.9));
            usingDataContractList[_idContractMongo].ownerApproved = true;
        }
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
        usingDataContractOfAUser[_idFile].push(mainContract);
        emit Log_signUsingDataContract(_idFile);
    }

    // Huỷ hợp đồng
    function cancelContract(string memory _idContractMongo) public isValidUser(msg.sender) {
        require(usingDataContractList[_idContractMongo].isCancel == false);
        require(usingDataContractList[_idContractMongo].ownerApproved == true && usingDataContractList[_idContractMongo].signerApproved == true);
        require(msg.sender == usingDataContractList[_idContractMongo].signer || msg.sender == usingDataContractList[_idContractMongo].owner);
        usingDataContractList[_idContractMongo].isCancel = true;
        if(msg.sender == usingDataContractList[_idContractMongo].owner){
            // transfer ether compensation
        }
        if(msg.sender == usingDataContractList[_idContractMongo].signer){
            // transfer ether compensation
        }
    }

    // Get using data contract
    function getUsingDataContract(string memory _idContractMongo) public view isValidUser(msg.sender) returns(usingDataContract memory) {
        return usingDataContractList[_idContractMongo];
    }

    // Get owner of using data contract
    function getOwnerContract(string memory _idContractMongo) public view isValidUser(msg.sender) returns(address){
        return usingDataContractList[_idContractMongo].owner;
    }
    
    //Get signer of using data contract 
    function getSignerContract(string memory _idContractMongo) public view isValidUser(msg.sender) returns(address){
        return usingDataContractList[_idContractMongo].signer;
    }

    // Create survey to collect infomation
    function createSurvey(
        string _idMongoose,
        string _contentHash,
        uint _endDay,
        uint _feePerASurvey,
        uint _surveyInDemand// the number of survey need to take
    ) public isValidUser(msg.sender) payable {
        require(msg.sender.balance > _feePerASurvey.mul(_surveyInDemand),"Your balance is not enough!!");
        require(msg.value > __feePerASurvey.mul(_surveyInDemand),"You haven't transfer money for this action!");
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
    }

    //take Survey
    function takeSurvey(uint _idSurvey) public isValidUser(msg.sender){
        require(survey[_idSurvey].endDate > now,"Survey is expired!");
        require(survey[_idSurvey].surveyInDemand < survey[_idSurvey].participatedPeople,"This survey is enough people!");
        survey[_idSurvey].participatedPeople = survey[_idSurvey].participatedPeople.add(1);
        UserList[msg.sender].activity = UserList[msg.sender].activity.add(1);
        // chuyen tien
    }

    // Update latest ranking
    function getRanking() {

    }

    // import personal information
    function setPersonalInformation() {

    }

    // view personal information
    function getMyPersonalInformation() {

    }

    // share personal information
    function publishInformation(){

    }

    // Using personal Information
    function getPublishedInformation(){

    }
}

// check validality of user
// 