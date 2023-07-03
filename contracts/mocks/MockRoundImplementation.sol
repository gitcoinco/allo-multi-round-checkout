// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../MultiRoundCheckout.sol";

contract MockRoundImplementation is IVotable {
    bytes[] public receivedVotes;
    bool public tryReentrancy;

    function setReentrant(bool _tryReentrancy) public {
        tryReentrancy = _tryReentrancy;
    }

    function vote(bytes[] memory data) external payable {
        if (tryReentrancy)  {
            address[] memory rounds = new address[](1);
            bytes[][] memory votes = new bytes[][](1);
            uint256[] memory amounts = new uint256[](1);
            rounds[0] = address(this);
            votes[0] = data;
            amounts[0] = msg.value;
            MultiRoundCheckout(msg.sender).vote{value: msg.value}(votes, rounds, amounts);
        }
        receivedVotes = data;
    }    

    function getReceivedVotes() public view returns (bytes[] memory) {
        return receivedVotes;
    }
}