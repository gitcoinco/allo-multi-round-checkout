// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../MultiRoundCheckout.sol";
import "./MockVotingStrategy.sol";

contract MockRoundImplementationERC20 is IVotable {
    bytes[] public receivedVotes;
    bool public tryReentrancy;

    constructor(address _votingStrategy) {
        votingStrategy = _votingStrategy;
    }

    function setReentrant(bool _tryReentrancy) public {
        tryReentrancy = _tryReentrancy;
    }

    function vote(bytes[] memory data) external payable override {
        if (tryReentrancy) {
            address[] memory rounds = new address[](1);
            bytes[][] memory votes = new bytes[][](1);
            uint256[] memory amounts = new uint256[](1);
            uint256 totalAmount = msg.value;
            address token = address(this);
            uint8 v = 0;
            bytes32 r = 0;
            bytes32 s = 0;
            rounds[0] = address(this);
            votes[0] = data;
            amounts[0] = msg.value;
            MultiRoundCheckout(msg.sender).voteERC20Permit(
                votes, rounds, amounts, totalAmount, token, type(uint256).max, v, r, s
            );
        }
        receivedVotes = data;
        MockVotingStrategy(votingStrategy).vote(data, msg.sender);
    }

    function getReceivedVotes() public view returns (bytes[] memory) {
        return receivedVotes;
    }
}
