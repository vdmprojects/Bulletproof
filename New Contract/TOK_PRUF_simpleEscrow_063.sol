/*  TO DO
 * verify security and user permissioning /modifiers
 *
 * mint a token at asset creation
 *
 * @implement remint_asset ?
 *-----------------------------------------------------------------------------------------------------------------
 * Should all assets have a token, minted to reside within the contract for curated / "nontokenized" asset classes?
 * If so, make a move-token function that can be enabled later (set to an address to control it)
 *-----------------------------------------------------------------------------------------------------------------
 *
 * IMPORTANT NOTE : DO NOT REMOVE FROM CODE:
 *      Verification of rgtHash in curated, tokenless asset classes are not secure beyond the honorable intentions
 * of authorized recorders. All blockchain info is readable, so a bad actor could trivially obtain a copy of the
 * correct rgtHash on chain. This "stumbling block" measure is in place primarily to keep honest people honest, and
 * to require an actual, malicious effort to bypass security rather than a little copy-paste. Actual decentralized
 * security is provided with tokenized assets, which do not rely on the coercive trust relationship that creates the
 * incentive for recorders not to engage in malicious practices.
 *
 * Order of require statements:
 * 1: (modifiers)
 * 2: checking the asset existance
 * 3: checking the idendity and credentials of the caller
 * 4: checking the suitability of provided data for the proposed operation
 * 5: checking the suitability of asset details for the proposed operation
 * 6: verifying that provided verification data matches required data
 * 7: verifying that message contains any required payment
 *
 *
 * Contract Resolution Names -
 *  assetToken
 *  assetClassToken
 *  PRUF_APP
 *  PRUF_NP
 *  PRUF_simpleEscrow
 *
 *
 * CONTRACT Types (storage)
 * 0   --NONE
 * 1   --Custodial
 * 2   --Non-Custodial
 * Owner (onlyOwner)
 * other = unauth
 *
 *
 * Record status field key
 *
 * 0 = no status, Non transferrable. Default asset creation status
 *       default after FMR, and after status 5 (essentially a FMR) (IN frontend)
 * 1 = transferrable
 * 2 = nontransferrable
 * 3 = stolen
 * 4 = lost
 * 5 = transferred but not reImported (no new rghtsholder information) implies that asset posessor is the owner.
 *       must be re-imported by ACadmin through regular onboarding process
 *       no actions besides modify RGT to a new rightsholder can be performed on a statuss 5 asset (no status changes) (Frontend)
 * 6 = in supervised escrow, locked until timelock expires, but can be set to lost or stolen
 *       Status 1-6 Actions cannot be performed by automation.
 *       only ACAdmins can set or unset these statuses, except 5 which can be set by automation
 * 7 = out of Supervised escrow (user < 5)
 *
 * 50 Locked escrow
 * 51 = transferrable, automation set/unset (secret confirmed)(ACAdmin can unset)
 * 52 = non-transferrable, automation set/unset (secret confirmed)(ACAdmin can unset)
 * 53 = stolen (automation set)(ONLY ACAdmin can unset)
 * 54 = lost (automation set/unset)(ACAdmin can unset)
 * 55 = asset transferred automation set/unset (secret confirmed)(ACAdmin can unset)
 * 56 = escrow - automation set/unset (secret confirmed)(ACAdmin can unset)
 * 57 = out of escrow
 * 58 = out of locked escrow
 *
 * escrow status = lock time set to a time instead of a block number
 *
 *
 * Authorized User Types   registeredUsers[]
 *
 * 1 - 4 = Standard User types
 * 1 - all priveleges
 * 2 - all but force-modify
 * 5 - 9 = Robot (cannot create of force-modify)
 * Other = unauth
 *
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_core_063.sol";

contract PRUF_simpleEscrow is PRUF {
    using SafeMath for uint256;

    address internal PrufAppAddress;
    PrufAppInterface internal PrufAppContract; //erc721_token prototype initialization

   /*
     * @dev Verify user credentials
     * Originating Address:
     *      holds asset token at idxHash
     */

    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenID = uint256(_idxHash);
        require(
                 (AssetTokenContract.ownerOf(tokenID) == msg.sender), //msg.sender is token holder
            "PC:MOD-IA: Caller does not hold token"
        );
        _;
    }

    function OO_ResolveContractAddresses()
        external
        override
        nonReentrant
        onlyOwner
    {
        //^^^^^^^checks^^^^^^^^^
        AssetClassTokenAddress = Storage.resolveContractAddress(
            "assetClassToken"
        );
        AssetClassTokenContract = AssetClassTokenInterface(
            AssetClassTokenAddress
        );

        AssetTokenAddress = Storage.resolveContractAddress("assetToken");
        AssetTokenContract = AssetTokenInterface(AssetTokenAddress);

        PrufAppAddress = Storage.resolveContractAddress("PRUF_APP");
        PrufAppContract = PrufAppInterface(PrufAppAddress);
        //^^^^^^^effects^^^^^^^^^
    }

    function getUser() internal override view returns (User memory) {
        //User memory callingUser = getUser();
        User memory user;
        (user.userType, user.authorizedAssetClass) = PrufAppContract.getUserExt(
            keccak256(abi.encodePacked(msg.sender))
        );
        return user;
        //^^^^^^^interactions^^^^^^^^^
    }
//--------------------------------------------External Functions--------------------------
    function setEscrow(
        bytes32 _idxHash,
        uint256 _escrowTime,
        uint8 _escrowStatus,
        bytes32 _escrowOwnerHash
    ) external nonReentrant isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        uint256 escrowTime = now.add(_escrowTime);
        uint8 newAssetStatus;

        require((rec.rightsHolder != 0), "SE: Record does not exist");
        require(
            (rec.assetStatus > 49),
            "PNP:MS: Only custodial usertype can change status < 50"
        );
        require(
            (escrowTime >= now),
            "SE:ERR-Escrow must be set to a time in the future"
        );
        require(
            (rec.assetStatus != 3) &&
                (rec.assetStatus != 4) &&
                (rec.assetStatus != 53) &&
                (rec.assetStatus != 54) &&
                (rec.assetStatus != 5) &&
                (rec.assetStatus != 55),
            "SE:ERR-Transferred, lost, or stolen status cannot be set to escrow."
        );
        require(
            (_escrowStatus == 6) ||
                (_escrowStatus == 50) ||
                (_escrowStatus == 56),
            "SE:ERR-Must specify an valid escrow status"
        );
        require(
            (_escrowStatus > 49),
            "PNP:MS: Only custodial usertype can set escrow < 50"
        );
        //^^^^^^^checks^^^^^^^^^

        newAssetStatus = _escrowStatus;

        //^^^^^^^effects^^^^^^^^^

        Storage.setEscrow(
            _escrowOwnerHash,
            _idxHash,
            newAssetStatus,
            escrowTime
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    function endEscrow(bytes32 _idxHash)
        external
        nonReentrant
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        Record memory shortRec = getShortRecord(_idxHash);
        User memory callingUser = getUser();

        require((rec.rightsHolder != 0), "EE: Record does not exist");
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "EE: User not authorized to modify records in specified asset class"
        );
        require(
            (rec.assetStatus == 6) ||
                (rec.assetStatus == 50) ||
                (rec.assetStatus == 56),
            "EE:ERR- record must be in escrow status"
        );
        require(
            (rec.assetStatus > 49),
            "EE:ERR- Custodial usertype required to end this escrow"
        );
        require(
            (shortRec.timeLock < now) ||
                (keccak256(abi.encodePacked(msg.sender)) == rec.recorder),
            "EE:ERR- Escrow period not ended"
        );
        //^^^^^^^checks^^^^^^^^^

        Storage.endEscrow(keccak256(abi.encodePacked(msg.sender)), _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }
}