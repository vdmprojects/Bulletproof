/*--------------------------------------------------------PRüF0.8.0
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
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PRUF_BASIC.sol";
//import "./PRUF_INTERFACES.sol";
import "./Imports/utils/ReentrancyGuard.sol";

contract ECR_CORE is BASIC {
    function _setEscrowData(
        bytes32 _idxHash,
        uint8 _newAssetStatus,
        bytes32 _escrowOwnerAddressHash,
        uint256 _timelock
    ) internal whenNotPaused {
        ECR_MGR.setEscrow(
            _idxHash,
            _newAssetStatus,
            _escrowOwnerAddressHash,
            _timelock
        );
    }

    function _setEscrowDataLight(
        bytes32 _idxHash,
        escrowDataExtLight memory escrowDataLight
    ) internal whenNotPaused {
        ECR_MGR.setEscrowDataLight(_idxHash, escrowDataLight);
        //^^^^^^^interactions^^^^^^^^^
    }

    function _setEscrowDataHeavy(
        bytes32 _idxHash,
        escrowDataExtHeavy memory escrowDataHeavy
    ) internal whenNotPaused {
        ECR_MGR.setEscrowDataHeavy(_idxHash, escrowDataHeavy);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev retrieves escrow data and returns escrow struct
     */
    function getEscrowData(bytes32 _idxHash)
        internal
        returns (escrowData memory)
    {
        //^^^^^^^checks^^^^^^^^^

        escrowData memory escrow = ECR_MGR.retrieveEscrowData(_idxHash);

        return (escrow);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev retrieves extended escrow data and returns escrowDataExtLight struct
     */
    function getEscrowDataLight(bytes32 _idxHash)
        internal
        view
        returns (escrowDataExtLight memory)
    {
        //^^^^^^^checks^^^^^^^^^

        escrowDataExtLight memory escrowDataLight =
            ECR_MGR.retrieveEscrowDataLight(_idxHash);

        return (escrowDataLight);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev retrieves extended escrow data and returns escrowDataExtHeavy struct
     */
    function getEscrowDataHeavy(bytes32 _idxHash)
        internal
        view
        returns (escrowDataExtHeavy memory)
    {
        //^^^^^^^checks^^^^^^^^^

        escrowDataExtHeavy memory escrowDataHeavy =
            ECR_MGR.retrieveEscrowDataHeavy(_idxHash);

        return (escrowDataHeavy);
        //^^^^^^^interactions^^^^^^^^^
    }
}
