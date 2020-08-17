/*-----------------------------------------------------------V0.6.7
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
pragma solidity ^0.6.7;

import "./Imports/Ownable.sol";

interface erc721_tokenInterface {
    function ownerOf(uint256) external view returns (address);
}

contract Helper is Ownable {
    address erc721ContractAddress;
    erc721_tokenInterface erc721_tokenContract; //erc721_token prototype initialization

    function setErc721_tokenAddress(address contractAddress) public onlyOwner {
        require(contractAddress != address(0), "Invalid contract address");
        erc721ContractAddress = contractAddress;
        erc721_tokenContract = erc721_tokenInterface(contractAddress);
    }

    function atWhatAddress(uint256 tokenId)
        external
        view
        onlyOwner
        returns (address)
    {
        return erc721_tokenContract.ownerOf(tokenId);
    }

    function atWhatAddressTokenB32(bytes32 _tokenID)
        external
        view
        onlyOwner
        returns (address)
    {
        uint256 tokenId = uint256(_tokenID);
        return erc721_tokenContract.ownerOf(tokenId);
    }

    function atMyAddress(uint256 tokenId)
        external
        view
        returns (string memory)
    {
        if (erc721_tokenContract.ownerOf(tokenId) == msg.sender) {
            return "token confirmed at sender address";
        } else {
            return "token not at sender address";
        }
    }

    function getBlock() external view returns (uint256) {
        return (block.number);
    }

    function getTime() external view returns (uint256) {
        return (block.timestamp);
    }

    function getStringHash(string calldata _idx)
        external
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_idx));
    }

    function getB32Hash(bytes32 _idx) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_idx));
    }

    function getAddrHash(address _idx) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_idx));
    }

    function getUint256Hash(uint256 _idx) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_idx));
    }

    function b32_to_uint256(bytes32 b32) external pure returns (uint256) {
        return uint256(b32);
    }

    function uint256_to_b32(uint256 u256) external pure returns (bytes32) {
        return bytes32(u256);
    }

    function getIdxHash(
        string memory _idx_type,
        string memory _idx_mfg,
        string memory _idx_mod,
        string memory _idx_ser
    ) public pure returns (bytes32) {
        bytes32 idxHash;
        idxHash = keccak256(
            abi.encodePacked(_idx_type, _idx_mfg, _idx_mod, _idx_ser)
        );
        return (idxHash);
    }

    function getRgtHash(
        bytes32 _idxHash,
        string memory _rgt_first,
        string memory _rgt_mid,
        string memory _rgt_last,
        string memory _rgt_ID,
        string memory _rgt_secret
    ) public pure returns (bytes32, bytes32) {
        bytes32 rawRgtHash;

        rawRgtHash = keccak256(
            abi.encodePacked(
                _rgt_first,
                _rgt_mid,
                _rgt_last,
                _rgt_ID,
                _rgt_secret
            )
        );
        return (rawRgtHash, keccak256(abi.encodePacked(_idxHash, rawRgtHash)));
    }

    function getJustRgtHash(
        bytes32 _idxHash,
        string memory _rgt_first,
        string memory _rgt_mid,
        string memory _rgt_last,
        string memory _rgt_ID,
        string memory _rgt_secret
    ) public pure returns (bytes32) {
        bytes32 rawRgtHash;

        rawRgtHash = keccak256(
            abi.encodePacked(
                _rgt_first,
                _rgt_mid,
                _rgt_last,
                _rgt_ID,
                _rgt_secret
            )
        );
        return (keccak256(abi.encodePacked(_idxHash, rawRgtHash)));
    }

    function getFuckyRgtHash(
        bytes32 _idxHash,
        string memory _rgt_first,
        string memory _rgt_mid,
        string memory _rgt_last,
        string memory _rgt_ID,
        string memory _rgt_secret
    ) public pure returns (bytes32) {
        bytes32 rawRgtHash;

        rawRgtHash = keccak256(
            abi.encodePacked(
                _rgt_first,
                _rgt_mid,
                _rgt_last,
                _rgt_ID,
                _rgt_secret,
                _idxHash
            )
        );
        return rawRgtHash;
    }

    function getNakedTokenHash(uint16 _assetClass, string memory _authCode)
        public
        pure
        returns (uint256)
    {
        bytes32 tokHash;

        tokHash = keccak256(abi.encodePacked(_assetClass, _authCode));
        uint256 uintHash = uint256(tokHash);

        return uintHash;
    }

    function uint256toString(uint256 number)
        public
        pure
        returns (string memory)
    {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (number == 0) {
            return "0";
        }
        uint256 temp = number;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = number;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + (temp % 10)));
            temp /= 10;
        }
        return string(buffer);
    }
}