/*--------------------------------------------------------PRuF0.7.1
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\../\\ ___/\\\\\\\\\\\\\\\
 _\/\\\/////////\\\ _/\\\///////\\\ ____\//..\//____\/\\\///////////__
  _\/\\\.......\/\\\.\/\\\.....\/\\\ ________________\/\\\ ____________
   _\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\.\/\\\\\\\\\\\ ____
    _\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\.\/\\\///////______
     _\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\.\/\\\ ____________
      _\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\.\/\\\ ____________
       _\/\\\ ____________\/\\\ _____\//\\\.\//\\\\\\\\\ _\/\\\ ____________
        _\/// _____________\/// _______\/// __\///////// __\/// _____________
         *-------------------------------------------------------------------*/

/*-----------------------------------------------------------------
 *  TO DO
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.7;

import "./PRUF_INTERFACES.sol";
import "./Imports/access/AccessControl.sol";
import "./Imports/token/ERC20/ERC20Burnable.sol";
import "./Imports/utils/Pausable.sol";
import "./Imports/token/ERC20/ERC20Snapshot.sol";

/**
 * @dev {ERC20} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a MINTER_ROLE that allows for token minting (creation)
 *  - a PAUSER_ROLE that allows to stop all token transfers
 *  - a SNAPSHOT_ROLE that allows to take snapshots
 *  - a PAYABLE_ROLE role that allows authorized adresses to invoke the token splitting payment function (all paybale contracts)
 *  - a TRUSTED_AGENT_ROLE role that allows authorized adresses to transfer and burn tokens (AC_MGR)




 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 */
contract UTIL_TKN is
    Context,
    AccessControl,
    ERC20Burnable,
    Pausable,
    ERC20Snapshot
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant SNAPSHOT_ROLE = keccak256("SNAPSHOT_ROLE");
    bytes32 public constant PAYABLE_ROLE = keccak256("PAYABLE_ROLE");
    bytes32 public constant TRUSTED_AGENT_ROLE = keccak256("TRUSTED_AGENT_ROLE");

    uint256 public constant maxSupply = 4000000000000000000000000000; //4billion max supply

    address private sharesAddress = address(0);

    struct Invoice {
        //invoice struct to facilitate payment messaging in-contract
        address rootAddress;
        uint256 rootPrice;
        address ACTHaddress;
        uint256 ACTHprice;
    }

    uint256 trustedAgentEnabled = 1;

    mapping(address => uint256) private coldWallet;

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * See {ERC20-constructor}.
     */
    constructor() public ERC20("PRuF_TKN", "PRuF") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    //------------------------------------------------------------------------MODIFIERS

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      is Admin
     */
    modifier isAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "PRUF:MOD: must have DEFAULT_ADMIN_ROLE"
        );
        _;
    }

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      is Pauser
     */
    modifier isPauser() {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "PRUF:MOD: must have PAUSER_ROLE"
        );
        _;
    }

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      is Minter
     */
    modifier isMinter() {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "PRUF:MOD: must have MINTER_ROLE"
        );
        _;
    }

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      is Payable in pruf
     */
    modifier isPayable() {
        require(
            hasRole(PAYABLE_ROLE, _msgSender()),
            "PRUF:MOD: must have PAYABLE_ROLE"
        );
        require( //---------------------------------------------------DPS:TEST : NEW
            trustedAgentEnabled == 1,
            "PRUF:MOD: Trusted Payable Function permanently disabled - use allowance / transferFrom pattern"
        );
        _;
    }

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      is Trusted Agent
     */
    modifier isTrustedAgent() {
        require(
            hasRole(TRUSTED_AGENT_ROLE, _msgSender()),
            "PRUF:MOD: must have TRUSTED_AGENT_ROLE"
        );
        require( //---------------------------------------------------DPS:TEST : NEW
            trustedAgentEnabled == 1,
            "PRUF:MOD: Trusted Agent function permanently disabled - use allowance / transferFrom pattern"
        );
        _;
    }

    /*
     * @dev PERMANANTLY !!!  Kill trusted agent and payable functions
     * this will break functionality of current payment mechanisms.
     */
    function adminKillTrustedAgent(uint256 _key) external isAdmin {
        //---------------------------------------------------DPS:TEST : NEW
        if (_key == 170) {
            trustedAgentEnabled = 0; //-------------------THIS IS A PERMANENT ACTION AND CANNOT BE UNDONE
        }
    }

    /*
     * @dev Set calling wallet to a "cold Wallet" that cannot be manipulated by TRUSTED_AGENT or PAYABLE permissioned functions
     * WALLET ADRESSES SET TO "Cold" DO NOT WORK WITH TRUSTED_AGENT FUNCTIONS
     */
    function setColdWallet() external {
        //---------------------------------------------------DPS:TEST : NEW
        coldWallet[msg.sender] = 170;
    }

    /*
     * @dev un-set calling wallet to a "cold Wallet", enabling manipulation by TRUSTED_AGENT and PAYABLE permissioned functions
     * WALLET ADRESSES SET TO "Cold" DO NOT WORK WITH TRUSTED_AGENT FUNCTIONS
     */
    function unSetColdWallet() external {
        //---------------------------------------------------DPS:TEST : NEW
        coldWallet[msg.sender] = 0;
    }

    /*
     * @dev return an adresses "cold wallet" status
     * WALLET ADRESSES SET TO "Cold" DO NOT WORK WITH TRUSTED_AGENT FUNCTIONS
     */
    function isColdWallet(address _addr) external view returns (uint256) {
        return coldWallet[_addr];
    }

    /*
     * @dev Set adress of SHARES payment contract. by default contract will use root adress instead if set to zero.
     */
    function AdminSetSharesAddress(address _paymentAddress) external isAdmin {
        require(
            _paymentAddress != address(0),
            "PRuF:SSA: payment address cannot be zero"
        );

        //^^^^^^^checks^^^^^^^^^

        sharesAddress = _paymentAddress;
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Deducts token payment from transaction
     */
    function payForService(
        address _senderAddress,
        address _rootAddress,
        uint256 _rootPrice,
        address _ACTHaddress,
        uint256 _ACTHprice
    ) external isPayable {
        require( //---------------------------------------------------DPS:TEST : NEW
            coldWallet[_senderAddress] == 0,
            "PRuF:PPS: Cold Wallet - Trusted payable functions prohibited"
        );
        require( //redundant? throws on transfer?
            balanceOf(_senderAddress) >= _rootPrice.add(_ACTHprice),
            "PRuF:PPS: insufficient balance"
        );
        //^^^^^^^checks^^^^^^^^^

        if (sharesAddress == address(0)) { //IF SHARES ADDRESS IS NOT SET
            _transfer(_senderAddress, _rootAddress, _rootPrice);
            _transfer(_senderAddress, _ACTHaddress, _ACTHprice);
        } else { //IF SHARES ADDRESS IS SET
            uint256 sharesShare = _rootPrice.div(uint256(4)); // sharesShare is 0.25 share of root costs
            uint256 rootShare = _rootPrice.sub(sharesShare); // adjust root price to be root price - 0.25 share

            _transfer(_senderAddress, _rootAddress, rootShare);
            _transfer(_senderAddress, sharesAddress, sharesShare);
            _transfer(_senderAddress, _ACTHaddress, _ACTHprice);
        }
        //^^^^^^^effects / interactions^^^^^^^^^
    }

    /*
     * @dev arbitrary burn (requires TRUSTED_AGENT_ROLE)   ****USE WITH CAUTION
     */
    function trustedAgentBurn(address _addr, uint256 _amount)
        public
        isTrustedAgent
    {
        require( //---------------------------------------------------DPS:TEST : NEW
            coldWallet[_addr] == 0,
            "PRuF:BRN: Cold Wallet - Trusted functions prohibited"
        );
        //^^^^^^^checks^^^^^^^^^
        _burn(_addr, _amount);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev arbitrary transfer (requires TRUSTED_AGENT_ROLE)   ****USE WITH CAUTION
     */
    function trustedAgentTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) public isTrustedAgent {
        require( //---------------------------------------------------DPS:TEST : NEW
            coldWallet[_from] == 0,
            "PRuF:TAT: Cold Wallet - Trusted functions prohibited"
        );
        //^^^^^^^checks^^^^^^^^^
        _transfer(_from, _to, _amount);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Take a balance snapshot, returns snapshot ID
     */
    function takeSnapshot() external returns (uint256) {
        require(
            hasRole(SNAPSHOT_ROLE, _msgSender()),
            "ERC20PresetMinterPauser: must have snapshot role to take a snapshot"
        );
        return _snapshot();
    }

    /**
     * @dev Creates `_amount` new tokens for `to`.
     *
     * See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to, uint256 _amount) public virtual isMinter {
        require(
            _amount.add(totalSupply()) <= maxSupply,
            "PRuF:M: mint request exceeds max supply"
        );
        //^^^^^^^checks^^^^^^^^^

        _mint(to, _amount);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual isPauser {
        //^^^^^^^checks^^^^^^^^^
        _pause();
        //^^^^^^^effects^^^^^^^^
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual isPauser {
        //^^^^^^^checks^^^^^^^^^
        _unpause();
        //^^^^^^^effects^^^^^^^^
    }

    function _beforeTokenTransfer( //all paused functions are blocked here, unless caller has "pauser" role
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);

        require(
            (!paused()) || hasRole(PAUSER_ROLE, _msgSender()),
            "ERC20Pausable: token transfer while paused"
        );
    }
}
