// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "./IVotable.sol";

error VotesNotEqualRoundsLength();
error ValuesNotEqualRoundsLength();
error ExcessValueSent();

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
     * votes is a 2d array. first index is the index of the round address in the second param.
     */
    function vote(
        bytes[][] memory votes,
        address[] memory rounds,
        uint256[] memory values
    ) public payable nonReentrant whenNotPaused {
        if (votes.length != rounds.length) {
            revert VotesNotEqualRoundsLength();
        }

        if (values.length != rounds.length) {
            revert ValuesNotEqualRoundsLength();
        }

        for (uint i = 0; i < rounds.length; i++) {
            IVotable round = IVotable(payable(rounds[i]));
            round.vote{value: values[i]}(votes[i]);
        }

        if (address(this).balance != 0) {
            revert ExcessValueSent();
        }
    }
}
