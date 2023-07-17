// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "./IVotable.sol";
import "./IDAIPermit.sol";

error VotesNotEqualRoundsLength();
error AmountsNotEqualRoundsLength();
error ExcessAmountSent();

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
     * vote: votes for multiple rounds at once with ETH.
     * votes is a 2d array. first index is the index of the round address in the second param.
     */
    function vote(
        bytes[][] memory votes,
        address[] memory rounds,
        uint256[] memory amounts
    ) public payable nonReentrant whenNotPaused {
        if (votes.length != rounds.length) {
            revert VotesNotEqualRoundsLength();
        }

        if (amounts.length != rounds.length) {
            revert AmountsNotEqualRoundsLength();
        }

        // possible previous balance + msg.value
        uint256 initialBalance = address(this).balance;

        for (uint256 i = 0; i < rounds.length;) {
            IVotable round = IVotable(payable(rounds[i]));
            round.vote{value: amounts[i]}(votes[i]);

            unchecked {
                ++i;
            }
        }

        if (address(this).balance != initialBalance - msg.value) {
            revert ExcessAmountSent();
        }
    }


    /**
     * voteERC20Permit: votes for multiple rounds at once with ERC20Permit tokens.
     */
    function voteERC20Permit(
        bytes[][] memory votes,
        address[] memory rounds,
        uint256[] memory amounts,
        uint256 totalAmount,
        address token,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public nonReentrant whenNotPaused {
        if (votes.length != rounds.length) {
            revert VotesNotEqualRoundsLength();
        }

        if (amounts.length != rounds.length) {
            revert AmountsNotEqualRoundsLength();
        }

        uint256 initialBalance = IERC20Upgradeable(token).balanceOf(address(this));

        try IERC20PermitUpgradeable(token).permit(
            msg.sender,
            address(this),
            totalAmount,
            deadline,
            v,
            r,
            s
        ) {} catch Error (string memory reason) {
            if ( IERC20Upgradeable(token).allowance(msg.sender, address(this)) < totalAmount) {
                revert(reason);
            }
        } catch (bytes memory reason) {
            if ( IERC20Upgradeable(token).allowance(msg.sender, address(this)) < totalAmount) {
               revert(string(reason));
            }
        }

        IERC20Upgradeable(token).transferFrom(msg.sender, address(this), totalAmount);

        for (uint256 i = 0; i < rounds.length;) {
            IVotable round = IVotable(rounds[i]);
            IERC20Upgradeable(token).approve(address(round.votingStrategy()), amounts[i]);
            round.vote(votes[i]);

            unchecked {
                ++i;
            }
        }

        if (IERC20Upgradeable(token).balanceOf(address(this)) != initialBalance) {
            revert ExcessAmountSent();
        }
    }

    /**
     * voteDAIPermit: votes for multiple rounds at once with DAI.
     */
    function voteDAIPermit(
        bytes[][] memory votes,
        address[] memory rounds,
        uint256[] memory amounts,
        uint256 totalAmount,
        address token,
        uint256 deadline,
        uint256 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public nonReentrant whenNotPaused {
        if (votes.length != rounds.length) {
            revert VotesNotEqualRoundsLength();
        }

        if (amounts.length != rounds.length) {
            revert AmountsNotEqualRoundsLength();
        }

        uint256 initialBalance = IERC20Upgradeable(token).balanceOf(address(this));

        try IDAIPermit(token).permit(
            msg.sender,
            address(this),
            nonce,
            deadline,
            true,
            v,
            r,
            s
        ) {} catch Error (string memory reason) {
            if ( IERC20Upgradeable(token).allowance(msg.sender, address(this)) < totalAmount) {
                revert(reason);
            }
        } catch (bytes memory reason) {
            if ( IERC20Upgradeable(token).allowance(msg.sender, address(this)) < totalAmount) {
               revert(string(reason));
            }
        }

        IERC20Upgradeable(token).transferFrom(msg.sender, address(this), totalAmount);

        for (uint256 i = 0; i < rounds.length;) {
            IVotable round = IVotable(rounds[i]);
            IERC20Upgradeable(token).approve(address(round.votingStrategy()), amounts[i]);
            round.vote(votes[i]);

            unchecked {
                ++i;
            }
        }

        if (IERC20Upgradeable(token).balanceOf(address(this)) != initialBalance) {
            revert ExcessAmountSent();
        }
    }
}
