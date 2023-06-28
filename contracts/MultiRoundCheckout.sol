// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../allo-contracts/contracts/round/IRoundImplementation.sol";
import "hardhat/console.sol";

contract MultiRoundCheckout is OwnableUpgradeable {
    address payable public owner;

    constructor(uint _unlockTime) payable {
        owner = payable(msg.sender);
    }

    /**
    * votes is a 2d array. first index is the address of the round.
    */
    function vote(bytes[][] calldata votes, address[] rounds) public {
        // console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp);
        for (uint i = 0; i < rounds.length; i++) {
            IRoundImplementation round = address(round[i]);
            bytes[] votesForRound = votes[i];
            round.vote(votesForRound);
        }
    }
}
