// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../allo-contracts/contracts/round/RoundImplementation.sol";

contract MultiRoundCheckout is OwnableUpgradeable {
    /**
    * votes is a 2d array. first index is the address of the round.
    */
    function vote(bytes[][] calldata votes, address[] calldata rounds) public {
        // console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp);
        for (uint i = 0; i < rounds.length; i++) {
            RoundImplementation round = RoundImplementation(payable(rounds[i]));
            bytes[] memory votesForRound = votes[i];
            round.vote(votesForRound);
        }
    }
}
