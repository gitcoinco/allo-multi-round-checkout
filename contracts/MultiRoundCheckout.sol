// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "./IVotable.sol";

error VotesNotEqualRoundsLength();
error AmountsNotEqualRoundsLength();
error ExcessAmountSent();
error PermitFailed(string reason);

contract MultiRoundCheckout is
    OwnableUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    function initialize() public initializer {
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * vote: votes for multiple rounds at once with ETH.
     * votes is a 2d array. first index is the index of the round address in the second param.
     */
    function vote(
        bytes[][] memory votes,
        address[] memory rounds,
        uint256[] memory amounts
    ) public payable nonReentrant whenNotPaused {
        if (votes.length != rounds.length) {
            revert VotesNotEqualRoundsLength();
        }

        if (amounts.length != rounds.length) {
            revert AmountsNotEqualRoundsLength();
        }

        for (uint i = 0; i < rounds.length; i++) {
            IVotable round = IVotable(payable(rounds[i]));
            round.vote{value: amounts[i]}(votes[i]);
        }

        if (address(this).balance != 0) {
            revert ExcessAmountSent();
        }
    }


    /**
     * voteERC20Permit: votes for multiple rounds at once with ERC20Permit tokens.
     */
    function voteERC20Permit(
        bytes[][] memory votes,
        address[] memory rounds,
        uint256[] memory amounts,
        uint256 totalAmount,
        address token,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public nonReentrant whenNotPaused {
        if (votes.length != rounds.length) {
            revert VotesNotEqualRoundsLength();
        }

        if (amounts.length != rounds.length) {
            revert AmountsNotEqualRoundsLength();
        }

        try IERC20PermitUpgradeable(token).permit(
            msg.sender,
            address(this),
            totalAmount,
            type(uint256).max,
            v,
            r,
            s
        ) {} catch Error (string memory reason) {
            if ( IERC20Upgradeable(token).allowance(msg.sender, address(this)) < totalAmount) {
                revert PermitFailed(reason);
            }
        } catch (bytes memory lowLevelData) {
            if ( IERC20Upgradeable(token).allowance(msg.sender, address(this)) < totalAmount) {
               revert PermitFailed(string(lowLevelData));
            }
        }

        IERC20Upgradeable(token).transferFrom(msg.sender, address(this), totalAmount);

        for (uint i = 0; i < rounds.length; i++) {
            IVotable round = IVotable(rounds[i]);
            IERC20Upgradeable(token).approve(address(round.votingStrategy()), amounts[i]);
            round.vote(votes[i]);
        }

        // ToDo: check if permit & approve works as expected

        if (IERC20Upgradeable(token).balanceOf(address(this)) != 0) {
            revert ExcessAmountSent();
        }
    }
}
