pragma solidity >=0.4.0 <0.7.0;

contract FileStruct {
    enum Kind{text, audio, image}

    struct usingDataContract{
        uint id; //id contract
        uint idFile; // id File data
        string dataHash;
        string contentHash;
        uint contractMoney;
        address owner;
        uint ownerCompensationAmount;
        bool ownerApproved;
        address signer;
        uint signerCompensationAmount;
        bool signerApproved;
        uint timeExpired;
        bool isCancel;
    }

    struct File{
        uint idFile;
        string idMongoose;
        string fileHash;
        address owner;
        uint price;
        uint totalUsed;
        uint weekUsed;
        uint blockTime;
        bool valid;
        Kind kind;
        uint feedback;
    }

    struct dataRanking{
        uint idFile;
        uint downloaded;
    }

    struct user{
        address ownerAddress;
        uint[] uploadList;
        uint[] usedList;
        bool isValid;
        uint surveyCreated;
        uint activity;
        uint reliability;
        individualData personalData;
    }

    struct individualData{
        address owner;
        string dataHash;
        // uint idIdentity;
        // string name;
        // uint DoB;
        // uint male; // 1: male, 2: female, 3: other
        // string hobbies;
        // string addressLive;
        // bool isMerried;
        // uint phone;
        bool shared;
    }
    
    struct Feedback{
        address ownerFeedback;
        string idMongo;//id in Mongo database to view content
        uint idFile;
    }
    
    struct Survey{
        uint idSurvey;
        address owner;
        string idMongoose;
        string contentHash;
        uint startDate;
        uint endDate;
        uint feePerASurvey;
        uint surveyInDemand; // the number of survey need to take
        uint participatedPeople;

    }
    
    struct huntedFile{
        uint idhuntFile;
        uint idhuntedFile;
        address peopleInNeed;
        string characteristicHash;
        address hunter;
        uint fee;
        bool isHunted;
    }
}
