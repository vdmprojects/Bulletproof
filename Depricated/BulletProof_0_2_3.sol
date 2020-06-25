pragma solidity ^0.6.0;

    /*****
     * @title BulletProof
     * @dev Store & retreive a record
     * Need to explore the implications of registering with serial only and reregistering with serial+secret
     * 
     * Authorization for registry changes from adress -> uint mapping?
     * 
     * Record status field key
     * 0 = no status, transferrable
     * 1 = transferrable
     * 2 = nontransferrable
     * 3 = stolen
     * 4 = lost
     * 255 = record locked (contract will not modify record without this first being unlocked by origin)
     * 
     * RegisteredUsers:
     * 0 = addressHash not authorized 
     * 9 = authorized for automation function
     * 
     * A Status 5 authorizes private sales, in which an point of sale app can verify that the "seller" can verify his/her
     * 
     * 
     */

import "./BP_Storage.sol";
import "./SafeMath.sol";

contract BulletProof is Storage {
    using SafeMath for uint8;
    using SafeMath for uint;
    
    
    /*
     * @dev Authorize / Deauthorize / Authorize automation for an address be permitted to make record modifications
     * ----------------INSECURE -- keccak256 of address must be generated clientside in release.
     */
    function authorize(address _authAddr, uint8 userType, uint16 _authorizedAssetClass) internal onlyOwner {
      
        require((userType == 0)||(userType == 1)||(userType == 9) ,
        "AUTH:ER:13"
        );
        
        bytes32 hash;
        hash = keccak256(abi.encodePacked(_authAddr));
        registeredUsers[hash].userType = userType;
        registeredUsers[hash].authorizedAssetClass = _authorizedAssetClass;
    }
    
    
    /*
     * @dev Administrative lock a database entry at index idx
     */
    function adminLock(bytes32 _idx) internal onlyOwner {
        
        checkRecord(_idx);
 
        database[_idx].status = 255;
        database[_idx].registrar = keccak256(abi.encodePacked(msg.sender));
    }
    
    
    /*
     * @dev Administrative unlock a database entry at index idx
     */
    function adminUnlock(bytes32 _idx) internal onlyOwner {
        
        require(
            database[_idx].registrant != 0 ,
            "AU:ER:3"
        );
        require(
            database[_idx].status == 255 ,
            "AU:ER:3"
        );
        
        
        database[_idx].status = 2;
        database[_idx].registrar = keccak256(abi.encodePacked(msg.sender));
    }
    
    
    /*
     * @dev Administrative reset of forceModCount to zero
     * Relies on onlyOwner from frontend
     */
    function resetForceModCount(bytes32 _idx) internal onlyOwner {
        
        checkRecord(_idx);
        
        require(
            database[_idx].forceModCount != 0 ,
            "FMC:ER:12"
        );
        
        
        database[_idx].forceModCount = 0;
    }


    /*
     * @dev Store a complete record at index idx
     */
    function newRecord(address _sender, bytes32 _idx, bytes32 _reg, string memory _desc, uint16 _assetClass, uint _countDownStart) internal {
       
        require(
            registeredUsers[keccak256(abi.encodePacked(_sender))].userType == 1 ,
            "NR:ER:1"
        );
        require(
            _assetClass == registeredUsers[keccak256(abi.encodePacked(_sender))].authorizedAssetClass ,
            "NR:ER:2"
        );
        require(
            database[_idx].registrant == 0 ,
            "NR:ER:10"
        );
        require(
            _reg != 0 ,
            "NR:ER:9"
        );
        
        database[_idx].assetClass = _assetClass;
        database[_idx].countDownStart = _countDownStart;
        database[_idx].countDown = _countDownStart;
        database[_idx].registrar = keccak256(abi.encodePacked(_sender));
        database[_idx].registrant = _reg;
        database[_idx].lastRegistrar = database[_idx].registrar;
        database[_idx].forceModCount = 0;
        database[_idx].description = _desc;
    }
    
    
    /*
     * @dev Store a permanant note at index idx
     */
        function addNote(address _sender, bytes32 _idx, bytes32 _reg, string memory _note) internal {
        authorizeUser(_sender, _idx);
        checkRecord(_idx);
        
        require(
            database[_idx].registrant == _reg ,
            "AN:ER:5"
        );
        require(
            keccak256(abi.encodePacked(database[_idx].note)) == keccak256(abi.encodePacked("")),
            "AN:ER:11"
        );
        
        lastRegistrar(_sender, _idx);


        database[_idx].note = _note;
    }
    
    
    /*
     * @dev force modify registrant at index idx
     */
    function forceModifyRecord(address _sender, bytes32 _idx, bytes32 _reg) internal {
       
        authorizeUser(_sender, _idx);
        checkRecord(_idx);
        
        require(
            _reg != 0 ,
            "FMR:ER:9"
        );
        require(
            database[_idx].registrant != _reg ,
            "FMR:ER:8"
        );
        
        uint8 count = database[_idx].forceModCount;
        
        if (count < 255) {
            count.add(1);
        }
        
        lastRegistrar(_sender, _idx);
        
        database[_idx].registrar = keccak256(abi.encodePacked(_sender));
        database[_idx].registrant = _reg;
        database[_idx].forceModCount = count;
    }
    
    
    /*
     * @dev Modify TRANSFER record REGISTRANT and STATUS with test for match to old record
     */
    function transferAsset (address _sender, bytes32 _idx, bytes32 _oldreg, bytes32 _newreg) internal {
        
        authorizeUser(_sender, _idx);
        checkRecord(_idx);
        
        require(
            database[_idx].registrant == _oldreg ,
            "TA:ER:5"
        );
        require(
            (database[_idx].status == 0) || (database[_idx].status == 1) ,
            "TA:ER:7"
        );
        require(
            _newreg != 0 ,
            "TA:ER:9"
        );
        require(
            database[_idx].registrant != _newreg ,
            "TA:ER:8"
        );
        
        lastRegistrar(_sender, _idx);
    
    
        database[_idx].registrar = keccak256(abi.encodePacked(_sender));
        database[_idx].registrant = _newreg;
    }
    
    
    /*
     * @dev decrements from current value of countDown in database. Starting value of countDown set on record creation
     */
    function decrementCountdown (address _sender, bytes32 _idx, bytes32 _reg, uint _decrementAmount) internal {
        
        authorizeUser(_sender, _idx);
        checkRecord(_idx);
        
        require(
            database[_idx].registrant == _reg ,
            "DC:ER:5"
        );
        
        database[_idx].registrar = keccak256(abi.encodePacked(_sender));
        database[_idx].countDown.sub(_decrementAmount);
    }
     
     
    /*
     * @dev Modify record STATUS with test for match to old record
     */
    function changeStatus (address _sender, bytes32 _idx, bytes32 _reg, uint8 _newstat) internal {
       
        authorizeUser(_sender, _idx);
        checkRecord(_idx);

        require(
            database[_idx].registrant == _reg ,
            "CS:ER:5"
        );
        require(
            _newstat != 255 ,
            "CS:ER:6"
        );
        
        
        
        database[_idx].registrar = keccak256(abi.encodePacked(_sender));
        database[_idx].status = _newstat;
    }
     
     
    /*
     * @dev user modify record DESCRIPTION with test for match to old record
     */
    function changeDescription (address _sender, bytes32 _idx, bytes32 _reg, string memory _desc) internal {
        
        authorizeUser(_sender, _idx);
        checkRecord(_idx);
        
        require(
            database[_idx].registrant == _reg ,
            "ER:5"
        );
        
        lastRegistrar(_sender, _idx);
        
        
        database[_idx].registrar = keccak256(abi.encodePacked(_sender));
        database[_idx].description = _desc;
    }
    
    
    function authorizeUser (address _sender, bytes32 _idx) internal view {
        uint8 senderType = registeredUsers[keccak256(abi.encodePacked(_sender))].userType;
        
        require(
            (senderType == 1) || (senderType == 9) ,
            "ER:1"
        );
        require(
            database[_idx].assetClass == registeredUsers[keccak256(abi.encodePacked(_sender))].authorizedAssetClass ,
            "ER:2"
        );
    }
    
    
    function checkRecord(bytes32 _idx) internal view {
        require(
            database[_idx].registrant != 0 ,
            "ER:3"
        );
        require(
            database[_idx].status != 255 ,
            "ER:4"
        );
        
    }
    
    /*
     * @dev Update lastRegistrant
     */ 
    function lastRegistrar(address _sender, bytes32 _idx) internal {
        bytes32 senderHash = keccak256(abi.encodePacked(_sender));
        
        if ((registeredUsers[database[_idx].registrar].userType == 1) && (senderHash != database[_idx].registrar)) {     // Rotate last registrar
                                                                                                                //into lastRegistrar field if uniuqe and not a robot
                                                                                                
            database[_idx].lastRegistrar = database[_idx].registrar;
        }
    }
}