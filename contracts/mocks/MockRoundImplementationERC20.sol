// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../MultiRoundCheckout.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract MockRoundImplementationERC20 is IVotable {
    bytes[] public receivedVotes;
    bool public tryReentrancy;

    constructor(address _votingStrategy) {
        votingStrategy = _votingStrategy;
    }

    function setReentrant(bool _tryReentrancy) public {
        tryReentrancy = _tryReentrancy;
    }

    function vote(bytes[] memory data) external override payable {
        if (tryReentrancy)  {
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
            MultiRoundCheckout(msg.sender).voteERC20Permit(votes, rounds, amounts, totalAmount, token, v, r, s);
        }
        receivedVotes = data;
        MockVotingStrategy(votingStrategy).vote(data, msg.sender);
    }    

    function getReceivedVotes() public view returns (bytes[] memory) {
        return receivedVotes;
    }
}

contract MockVotingStrategy {

    function vote(bytes[] memory _votes, address _voterAddress) external payable {
        for (uint256 i = 0; i < _votes.length; i++) {
            (
            address _token,
            uint256 _amount
            ) = abi.decode(_votes[i], (
                address,
                uint256
            ));
            IERC20Upgradeable(_token).transferFrom(_voterAddress, address(this), _amount);
        }

    }
}