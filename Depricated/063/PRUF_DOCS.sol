/*-----------------------------------------------------------------
 *  TO DO
 *
 * @implement remint_asset ?
*-----------------------------------------------------------------

*-----------------------------------------------------------------
 * IMPORTANT NOTE : DO NOT REMOVE FROM CODE:
 *      Verification of rgtHash in curated, tokenless asset classes are not secure beyond the honorable intentions
 * of authorized recorders. All blockchain info is readable, so a bad actor could trivially obtain a copy of the
 * correct rgtHash on chain. This "stumbling block" measure is in place primarily to keep honest people honest, and
 * to require an actual, malicious effort to bypass security rather than a little copy-paste. Actual decentralized
 * security is provided with tokenized assets, which do not rely on the coercive trust relationship that creates the
 * incentive for recorders not to engage in malicious practices.
*-----------------------------------------------------------------

*-----------------------------------------------------------------
 *rules for burning records:
 *
 *rules for reminting records:
 *
 *rules for recycling records:
 *  if recycled in same asset class group:
 *      in record: new rgtHash assigned, anything else left as-was (in case there was a pre-existing record)
 *      token is reissued to recycling address
 *  if recycled in new asset class group:
 *  
*-----------------------------------------------------------------

*-----------------------------------------------------------------
 * Order of require statements:
 * 1: (modifiers)
 * 2: checking the asset existance
 * 3: checking the idendity and credentials of the caller
 * 4: checking the suitability of provided data for the proposed operation
 * 5: checking the suitability of asset details for the proposed operation
 * 6: verifying that provided verification data matches required data
 * 7: verifying that message contains any required payment
*-----------------------------------------------------------------

*-----------------------------------------------------------------
 * Contract Resolution Names -
 *  assetToken
 *  assetClassToken
 *  PRUF_APP
 *  PRUF_NP
 *  PRUF_simpleEscrow
 *  PRUF_AC_MGR
 *  PRUF_AC_Minter
 *  T_PRUF_APP
 *  T_PRUF_NP
 *  T_PRUF_simpleEscrow
*-----------------------------------------------------------------

*-----------------------------------------------------------------
 * CONTRACT Types (storage)
 * 0   --NONE
 * 1   --Custodial
 * 2   --Non-Custodial
 * Owner (onlyOwner)
 * other = unauth
*-----------------------------------------------------------------

*-----------------------------------------------------------------
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
*-----------------------------------------------------------------

*-----------------------------------------------------------------
 *
 * escrow status = lock time set to a time instead of a block number
 *
 *
 * Authorized User Types   registeredUsers[]
 * 1 - 4 = Standard User types
 * 1 - all priveleges
 * 2 - all but force-modify
 * 5 - 9 = Robot (cannot create of force-modify)
 * Other = unauth
*-----------------------------------------------------------------
 */