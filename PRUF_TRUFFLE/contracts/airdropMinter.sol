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
 *
 *-----------------------------------------------------------------
 *PRUF basic provides core data structures and functionality to PRUF contracts.
 *Features include contract name resolution, and getters for records, users, and asset class information.
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_INTERFACES.sol";
import "./Imports/access/Ownable.sol";
import "./Imports/utils/Pausable.sol";
import "./Imports/utils/ReentrancyGuard.sol";
import "./Imports/token/ERC721/IERC721Receiver.sol";
import "./Imports/math/safeMath.sol";

contract AIR_MINTER is ReentrancyGuard, Ownable, IERC721Receiver, Pausable {
    address internal STOR_Address;
    STOR_Interface internal STOR;

    address internal UTIL_TKN_Address;
    UTIL_TKN_Interface internal UTIL_TKN;

    uint256 amount;

    //----------------------External Admin functions / onlyowner ---------------------//
    /*
     * @dev Resolve Contract Addresses from STOR
     */
    function OO_resolveContractAddresses()
        external
        virtual
        nonReentrant
        onlyOwner
    {
        //^^^^^^^checks^^^^^^^^^
        UTIL_TKN_Address = STOR.resolveContractAddress("UTIL_TKN");
        UTIL_TKN = UTIL_TKN_Interface(UTIL_TKN_Address);

        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Set adress of STOR contract to interface with
     */
    function OO_setStorageContract(address _storageAddress)
        external
        virtual
        onlyOwner
    {
        require(
            _storageAddress != address(0),
            "AM:SSC: storage address cannot be zero"
        );
        //^^^^^^^checks^^^^^^^^^

        STOR = STOR_Interface(_storageAddress);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Set adress of STOR contract to interface with
     */
    function OO_setAirdropAmount(uint256 _amount) external onlyOwner {
        require(_amount != 0, "AM:SAA: airdrop amount cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        amount = _amount;
        //^^^^^^^effects^^^^^^^^^
    }

    //--------------------------------------External functions--------------------------------------------//

    /*
     * @dev Mint a set amount to a list of addresses
     */
    function OO_bulkMint14(
        address _a,
        address _b,
        address _c,
        address _d,
        address _e,
        address _f,
        address _g,
        address _h,
        address _i,
        address _j,
        address _k,
        address _l,
        address _m,
        address _n
    ) external onlyOwner {
        require(amount != 0, "AM:BM: airdrop amount cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN.mint(_a, amount);
        UTIL_TKN.mint(_b, amount);
        UTIL_TKN.mint(_c, amount);
        UTIL_TKN.mint(_d, amount);
        UTIL_TKN.mint(_e, amount);
        UTIL_TKN.mint(_f, amount);
        UTIL_TKN.mint(_g, amount);
        UTIL_TKN.mint(_h, amount);
        UTIL_TKN.mint(_i, amount);
        UTIL_TKN.mint(_j, amount);
        UTIL_TKN.mint(_k, amount);
        UTIL_TKN.mint(_l, amount);
        UTIL_TKN.mint(_m, amount);
        UTIL_TKN.mint(_n, amount);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Mint a set amount to a list of addresses
     */
    function OO_bulkMint10(
        address _a,
        address _b,
        address _c,
        address _d,
        address _e,
        address _f,
        address _g,
        address _h,
        address _i,
        address _j
    ) external onlyOwner {
        require(amount != 0, "AM:BM: airdrop amount cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN.mint(_a, amount);
        UTIL_TKN.mint(_b, amount);
        UTIL_TKN.mint(_c, amount);
        UTIL_TKN.mint(_d, amount);
        UTIL_TKN.mint(_e, amount);
        UTIL_TKN.mint(_f, amount);
        UTIL_TKN.mint(_g, amount);
        UTIL_TKN.mint(_h, amount);
        UTIL_TKN.mint(_i, amount);
        UTIL_TKN.mint(_j, amount);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Mint a set amount to a list of addresses
     */
    function OO_bulkMint5(
        address _a,
        address _b,
        address _c,
        address _d,
        address _e
    ) external onlyOwner {
        require(amount != 0, "AM:BM: airdrop amount cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN.mint(_a, amount);
        UTIL_TKN.mint(_b, amount);
        UTIL_TKN.mint(_c, amount);
        UTIL_TKN.mint(_d, amount);
        UTIL_TKN.mint(_e, amount);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Mint a set amount to a list of addresses
     */
    function OO_bulkMint3(
        address _a,
        address _b,
        address _c
    ) external onlyOwner {
        require(amount != 0, "AM:BM: airdrop amount cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN.mint(_a, amount);
        UTIL_TKN.mint(_b, amount);
        UTIL_TKN.mint(_c, amount);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Mint a set amount to a list of addresses
     */
    function OO_bulkMint2(address _a, address _b) external onlyOwner {
        require(amount != 0, "AM:BM: airdrop amount cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN.mint(_a, amount);
        UTIL_TKN.mint(_b, amount);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Mint a set amount to a list of addresses
     */
    function OO_bulkMint1(address _a) external onlyOwner {
        require(amount != 0, "AM:BM: airdrop amount cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN.mint(_a, amount);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Compliance for erc721 reciever
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual override returns (bytes4) {
        //^^^^^^^checks^^^^^^^^^
        return this.onERC721Received.selector;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Triggers stopped state. (pausable)
     *
     */
    function OO_pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Returns to normal state. (pausable)
     */
    function OO_unpause() external onlyOwner {
        _unpause();
    }

    //--------------------------------------------------------------------------------------INTERNAL functions
}
