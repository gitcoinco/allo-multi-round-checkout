// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "./IVotable.sol";

contract MultiRoundCheckout is OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {
    /**
    * votes is a 2d array. first index is the index of the round address in the second param.
    */
    function vote(bytes[][] memory votes, address[] memory rounds) public nonReentrant {
        require(votes.length == rounds.length, "MultiRoundCheckout: votes and rounds length mismatch");
        for (uint i = 0; i < rounds.length; i++) {
            IVotable round = IVotable(payable(rounds[i]));
            round.vote{value: msg.value}(votes[i]);
        }
    }
}