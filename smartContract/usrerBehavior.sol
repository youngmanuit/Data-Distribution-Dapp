pragma solidity >=0.4.0 <0.7.0;
import "./fileStruct.sol";
import "./Ownable.sol";
import "./safemath.sol";

contract userBehavior is FileStruct, Ownable {
    using SafeMath for uint256;
    event Log_uploadData(address owner, Kind kind, uint idFile);
    event Log_downloadFile(address recipient, uint idFile);
    event Log_signUsingDataContract(uint idFile,address owner, address signer);
    event Log_takeFeedback(address ownerFeedback, uint idFile);
    event Log_createSurvey(address owner, uint idSurvey);
    event Log_sharingIndividualData(address indexed owner);
    event Log_withdraw(address recipient, uint amount);

    uint idFile = 0;
    Feedback[] public _feedback;
    mapping(address=>File[]) Filelist;
    mapping(uint=>File) files;
    mapping (string=>usingDataContract)usingDataContractList;

    modifier isValidFile(uint _idFile) {
        require(files[_idFile].valid,"File chưa đc xác thực");
        _;
    }
    // Upload data
    function uploadData(string memory _fileHash, uint _price, Kind _kind, string memory _idMongoose) public returns(uint) {
      idFile++;
      File memory tempFile = File(idFile,_idMongoose,_fileHash,msg.sender,_price,0,0,now,false,_kind,0);
      Filelist[msg.sender].push(tempFile);
      files[idFile] = tempFile;
      emit Log_uploadData(msg.sender,_kind,idFile);
      return idFile;
    }

    // Using data
    function downloadData(uint _idFile) public isValidFile(_idFile) returns(string memory) {
        require();
    }

    //Get owner of data
    function getUserUpload(uint _idFile) public view returns(user memory) {
        return files[_idFile].owner;
    }

    //Get file by idFile
    function getFileById(uint _idFile) public view returns(File memory) {
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
    ) public {
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
    function setApproved(){

    }

    // Huỷ hợp đồng
    function cancelContract(){

    }

    // Get using data contract
    function getUsingDataContract() {

    }

    // Get owner of using data contract
    function getOwnerContract(){}
    
    //Get signer of using data contract 
    function getSignerContractList(){

    }

    // Create survey to collect infomation
    function createSuvey() {
        
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

