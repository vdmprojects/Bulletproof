pragma solidity >=0.4.22 <0.7.0;

import "./Ownable.sol";

/**
 * @title BP_Storage
 * @dev Store & retreive a record
 * 
 * Authorization for registry changes from adress -> uint mapping?
 * 
 * Record status field key
 * 0 = no status, transferrable
 * 1 = transferrable
 * 2 = nontransferrable
 * 3 = stolen
 * 255 = record locked (contract will not modify record without this first being unlocked by origin)
 * 
 * 
 */

contract BP_Authorize is Ownable {
    
    struct Record {
        bytes32 registrar; // tokenID (or address) of registrant 
        bytes32 registrant;  // KEK256 Registered  owner
        uint8 status; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
    }
    
    mapping(uint => Record) public database; //registry
    mapping(bytes32 => uint8) private registeredUsers; //authorized registrar database
    


    /**
     * @dev Authorize an address to make record modifications
     * ----------------INSECURE -- keccak256 of address must be generated clientside in release.
     * something like:
     * 
     * function authorize(bytes32 authAddrHash) public onlyOwner {
     *   registeredUsers[authAddrHash] = 1;
     * }
     */
    function authorize(address authAddr) public onlyOwner {
        bytes32 hash;
        hash = keccak256(abi.encodePacked(authAddr));
        registeredUsers[hash] = 1;
    }

    /**
     * @dev De-authorize an address to make record modifications
     * * ----------------INSECURE -- keccak256 of address must be generated clientside in release.
     * something like:
     * 
     * function deauthorize(bytes32 authAddrHash) public onlyOwner {
     *   registeredUsers[authAddrHash] = 0;
     * }
     * 
     */
    
    function deauthorize(address authAddr) public onlyOwner {
        bytes32 hash;
        hash = keccak256(abi.encodePacked(authAddr));
        registeredUsers[hash] = 0;
    }
    
    
    /**
     * @dev update an address from an existing address to make record modifications
     * 
     * ----------------INSECURE -- keccak256 of address must be generated clientside in release.
     * something like:
     * 
     *function newAuthorize(bytes32 newAuthAddrHash) public {
     *    require(
     *        registeredUsers[keccak256(abi.encodePacked(msg.sender))] == 1 ,
     *        "Not authorized"
     *    );
     *    
     *    registeredUsers[newAuthAddrHash] = 1;
     *    
     *   registeredUsers[keccak256(abi.encodePacked(msg.sender))] = 0 ;
     *}
     * 
     */
    //-----------------------------------------------------This function and the activity it is designed to support (address hopping) will not meaningfully enhance security
    //function newAuthorize(address newAuthAddr) public {
    //    require(
    //        registeredUsers[keccak256(abi.encodePacked(msg.sender))] == 1 ,
    //        "Not authorized"
    //    );
    //    
    //    bytes32 hash;
    //    hash = keccak256(abi.encodePacked(newAuthAddr));
    //    registeredUsers[hash] = 1;
    //    registeredUsers[keccak256(abi.encodePacked(msg.sender))] = 0 ;
    //}

    /**
     * @dev Administrative Modify registrar field of aa database entry 
     * ----------------Security risk....probably should not be in production code
     */

    function ForceOverwriteRegistrar(uint idx, bytes32 regstrar) public onlyOwner {
        database[idx].registrar = regstrar;
        database[idx].registrar = keccak256(abi.encodePacked(msg.sender));
    }
    
    /**
     * @dev Administrative Modify registrant field of aa database entry 
     * ----------------Security risk....probably should not be in production code
     */

    function forceOverwriteRegistrant(uint idx, bytes32 regtrnt) public onlyOwner {
        database[idx].registrant = regtrnt;
        database[idx].registrar = keccak256(abi.encodePacked(msg.sender));
    }
    
    /**
     * @dev Administrative modify status field of a database entry
     * ----------------Security risk....probably should not be in production code
     */

    function forceOverwriteStatus(uint idx, uint8 stat) public onlyOwner{
        database[idx].status = stat;
        database[idx].registrar = keccak256(abi.encodePacked(msg.sender));
    }
    
     /**
     * @dev Administrative lock a database entry at index idx
     */

    function adminLock(uint idx) public onlyOwner{
        
        require(
            database[idx].status != 255 ,
            "Record already locked"
        );
        
        database[idx].status = 255;
        database[idx].registrar = keccak256(abi.encodePacked(msg.sender));
    }
    
    /**
     * @dev Administrative unlock a database entry at index idx
     */

    function adminUnLock(uint idx) public onlyOwner{
        
        require(
            database[idx].status == 255 ,
            "Record not locked"
        );
        
        database[idx].status = 2;            // set to notransferrable on unlock????????????????????!!!!!!!!!!!!!!!!!
        database[idx].registrar = keccak256(abi.encodePacked(msg.sender));
    }
    

    /**
     * @dev Store a complete record at index idx
     */
    function newRecord(uint idx, bytes32 regstrnt, uint8 stat) public {
        require(
            registeredUsers[keccak256(abi.encodePacked(msg.sender))] == 1 ,
            "Not authorized"
        );
        require(
            database[idx].registrant == 0 ,
            "Record already exists"
        );
        require(
            regstrnt != 0 ,
            "Registrant cannot be empty"
        );
        
        database[idx].registrar = keccak256(abi.encodePacked(msg.sender));
        database[idx].registrant = regstrnt;
        database[idx].status = stat;
    }

    
    
    /**
     * @dev modify record field 'status' at index idx
     */
    
    function modifyStatus(uint idx, uint8 stat) public {
        require(
            registeredUsers[keccak256(abi.encodePacked(msg.sender))] == 1 ,
            "Not authorized"
        );
        require(
            database[idx].registrant != 0 ,
            "No Record exists to modify"
        );
        require(
            database[idx].status != 255 ,
            "Record locked"
        );
        
        database[idx].registrar = keccak256(abi.encodePacked(msg.sender));
        database[idx].status = stat;
    }
    
    
        /**
     * @dev modify record field 'registrant' at index idx
     */
    
    function modifyRegistrant(uint idx, bytes32 regstrnt) public {
        require(
            registeredUsers[keccak256(abi.encodePacked(msg.sender))] == 1 ,
            "Not authorized"
        );
        require(
            database[idx].registrant != 0 ,
            "No Record exists to modify"
        );
        require(
            database[idx].status != 255 ,
            "Record locked"
        );
        require(
        database[idx].status != 2 ,
            "Asset marked nontransferrable"
        );
        require(
        database[idx].status != 3 ,
            "Asset reported stolen"
        );
        require(
        (database[idx].status == 0) || (database[idx].status == 1) ,
            "Tranfer prohibited"
        );
        require(
            regstrnt != 0 ,
            "Registrant cannot be empty"
        );
        
        database[idx].registrar = keccak256(abi.encodePacked(msg.sender));
        database[idx].registrant = regstrnt;
    }
    
    

    /**
     * @dev Return complete record from datatbase at index idx
     */

    function retrieveRecord (uint idx) public view returns (bytes32,bytes32,uint8){
        return (database[idx].registrar,database[idx].registrant,database[idx].status);
    }
    
}