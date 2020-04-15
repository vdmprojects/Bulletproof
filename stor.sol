pragma solidity 0.6.0;

import "./Ownable.sol";
/*
 */
contract Storage is Ownable {
    
    mapping (address => uint8) internal Users;
    
    mapping (uint8 => uint8) internal Data;
    
    
    /*
     * @dev Set Value
     */
    function SET_Data (uint8 _idx, uint8 _value) public returns (uint8){
        require(
            Users[msg.sender] == 1,
            "User unauthorized"
        );
        Data[_idx] = _value;
        return(_value);
    }
    
    function GET_Data (uint8 _idx) public view returns (uint8) {
        require(
            Users[msg.sender] == 1,
            "User unauthorized"
        );
        return Data[_idx];
    }
    
    function SET_User (address _addr) public onlyOwner {
        Users[_addr] = 1;
    }
    function DEL_User (address _addr) public onlyOwner {
        Users[_addr] = 0;
    }
    
}