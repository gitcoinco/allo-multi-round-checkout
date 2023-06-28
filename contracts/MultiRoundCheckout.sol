// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract MultiRoundCheckout is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    /**
    * votes is a 2d array. first index is the inde of the round address in the second param.
    */
    function vote(bytes[][] memory votes, address[] memory rounds) public nonReentrant {
        for (uint i = 0; i < rounds.length; i++) {
            IRoundImplementation round = IRoundImplementation(payable(rounds[i]));
            round.vote(votes[i]);
        }
    }
}

interface IRoundImplementation {
    function vote(bytes[] memory data) external payable;
}