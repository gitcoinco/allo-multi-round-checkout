
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

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