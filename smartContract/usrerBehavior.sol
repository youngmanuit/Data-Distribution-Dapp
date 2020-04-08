pragma solidity >=0.4.0 <0.7.0;
import "./fileStruct.sol";
import "./Ownable.sol";

contract userBehavior is FileStruct, Ownable {
    event Log_uploadData(address owner, Kind kind, uint idFile);
    event Log_downloadFile(address recipient, uint idFile);
    event Log_signUsingDataContract(uint idFile,address owner, address signer);
    event Log_takeFeedback(address ownerFeedback, uint idFile);
    event Log_createSurvey(address owner, uint idSurvey);
    event Log_sharingIndividualData(address indexed owner);
    event Log_withdraw(address recipient, uint amount);
    uint idFile = 0;
    Feedback[] public _feedback;

    function uploadData(string memory _fileHash, uint _price, Kind _kind, string memory _idMongoose) public returns(uint) {
      idFile++;
      File memory tempFile = File(idFile,_idMongoosen,_fileHash,msg.sender,_price,0,0,now,False,_kind,0);
    }
    function downloadData() {

    }
    function getUserUpload() {

    }
    function getFileById() {

    }
    function createContract() {

    }
    function setApproved(){

    }
    function cancelContract(){

    }
    function getUsingDataContract() {

    }
    function getOwnerContract(){}
    function getSignerContractList(){

    }
    function createSuvey() {
        
    }
    function getRanking() {

    }
    function setPersonalInformation() {

    }
    function getMyPersonalInformation() {

    }
    function publishInformation(){

    }
    function getPublishedInformation(){

    }
}

