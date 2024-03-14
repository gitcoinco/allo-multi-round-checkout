// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "./IVotable.sol";
import "./IDAIPermit.sol";
import "./IAllo.sol";

error VotesNotEqualRoundsLength();
error AmountsNotEqualRoundsLength();
error ExcessAmountSent();
error INVALID_INPUT();

contract MultiRoundCheckout is OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {
    modifier validateNativeBalance() {
        uint256 initialBalance = address(this).balance;
        _;
        if (address(this).balance != initialBalance - msg.value) {
            revert ExcessAmountSent();
        }
    }

    modifier validateErc20Balance(address token) {
        uint256 initialBalance = IERC20Upgradeable(token).balanceOf(address(this));
        _;
        if (IERC20Upgradeable(token).balanceOf(address(this)) != initialBalance) {
            revert ExcessAmountSent();
        }
    }

    function initialize(address _allo) public reinitializer(2) {
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        allo = IAllo(_allo);
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
    function vote(bytes[][] memory votes, address[] memory rounds, uint256[] memory amounts)
        public
        payable
        nonReentrant
        whenNotPaused
        validateNativeBalance
    {
        _validateV1Input(votes, rounds, amounts);

        uint256 roundsLength = rounds.length;
        for (uint256 i = 0; i < roundsLength;) {
            IVotable round = IVotable(payable(rounds[i]));
            round.vote{value: amounts[i]}(votes[i]);

            unchecked {
                ++i;
            }
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
    ) public nonReentrant whenNotPaused validateErc20Balance(token) {
        _validateV1Input(votes, rounds, amounts);
        _checkERC20Allowance(token, totalAmount, deadline, v, r, s);
        _handleVote(votes, rounds, amounts, totalAmount, token);
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
    ) public nonReentrant whenNotPaused validateErc20Balance(token) {
        _validateV1Input(votes, rounds, amounts);
        _checkDAIAllowance(token, totalAmount, deadline, nonce, v, r, s);
        _handleVote(votes, rounds, amounts, totalAmount, token);
    }

    function _handleVote(
        bytes[][] memory votes,
        address[] memory rounds,
        uint256[] memory amounts,
        uint256 totalAmount,
        address token
    ) internal {
        _transferToken(token, totalAmount);

        uint256 roundsLength = rounds.length;
        for (uint256 i = 0; i < roundsLength;) {
            IVotable round = IVotable(rounds[i]);
            IERC20Upgradeable(token).approve(address(round.votingStrategy()), amounts[i]);
            round.vote(votes[i]);

            unchecked {
                ++i;
            }
        }
    }

    function _checkERC20Allowance(address token, uint256 totalAmount, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        internal
    {
        try IERC20PermitUpgradeable(token).permit(msg.sender, address(this), totalAmount, deadline, v, r, s) {}
        catch Error(string memory reason) {
            if (IERC20Upgradeable(token).allowance(msg.sender, address(this)) < totalAmount) {
                revert(reason);
            }
        } catch (bytes memory reason) {
            if (IERC20Upgradeable(token).allowance(msg.sender, address(this)) < totalAmount) {
                revert(string(reason));
            }
        }
    }

    function _checkDAIAllowance(
        address token,
        uint256 totalAmount,
        uint256 deadline,
        uint256 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        try IDAIPermit(token).permit(msg.sender, address(this), nonce, deadline, true, v, r, s) {}
        catch Error(string memory reason) {
            if (IERC20Upgradeable(token).allowance(msg.sender, address(this)) < totalAmount) {
                revert(reason);
            }
        } catch (bytes memory reason) {
            if (IERC20Upgradeable(token).allowance(msg.sender, address(this)) < totalAmount) {
                revert(string(reason));
            }
        }
    }

    function _transferToken(address token, uint256 totalAmount) internal {
        IERC20Upgradeable(token).transferFrom(msg.sender, address(this), totalAmount);
    }

    function _validateV1Input(bytes[][] memory votes, address[] memory rounds, uint256[] memory amounts)
        internal
        pure
    {
        if (votes.length != rounds.length) {
            revert VotesNotEqualRoundsLength();
        }

        if (amounts.length != rounds.length) {
            revert AmountsNotEqualRoundsLength();
        }
    }

    /**
     *
     * Allo V2
     *
     */
    struct Allocations {
        address token;
        uint256 totalAmount;
        uint256[] poolIds;
        uint256[] amounts;
        bytes[] data;
    }

    IAllo public allo;

    /**
     * allocate: allocate donations for multiple rounds at once with ETH.
     * @param _poolIds Allo-v2 Pool Id to which to allocate the funds
     * @param _amounts Amounts to allocate to each pool
     * @param _data Encoded data to be passed to the Allo-v2 pool
     */
    function allocate(uint256[] memory _poolIds, uint256[] memory _amounts, bytes[] memory _data)
        public
        payable
        nonReentrant
        whenNotPaused
        validateNativeBalance
    {
        _validateV2Input(_poolIds, _amounts, _data);

        uint256 poolLength = _poolIds.length;
        for (uint256 i = 0; i < poolLength;) {
            allo.allocate{value: _amounts[i]}(_poolIds[i], _data[i]);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * allocateERC20Permit: allocate donations for multiple rounds at once with ERC20Permit tokens.
     */
    function allocateERC20Permit(
        bytes[] memory _data,
        uint256[] memory _poolIds,
        uint256[] memory _amounts,
        uint256 totalAmount,
        address token,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public nonReentrant whenNotPaused validateErc20Balance(token) {
        _checkERC20Allowance(token, totalAmount, deadline, v, r, s);
        _handleAllocate(Allocations(token, totalAmount, _poolIds, _amounts, _data));
    }

    /**
     * allocateDAIPermit: _data for multiple rounds at once with DAI.
     */
    function allocateDAIPermit(
        bytes[] memory _data,
        uint256[] memory _poolIds,
        uint256[] memory _amounts,
        uint256 totalAmount,
        address token,
        uint256 deadline,
        uint256 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public nonReentrant whenNotPaused validateErc20Balance(token) {
        _checkDAIAllowance(token, totalAmount, deadline, nonce, v, r, s);
        _handleAllocate(Allocations(token, totalAmount, _poolIds, _amounts, _data));
    }

    function updateAllo(address _allo) public onlyOwner {
        allo = IAllo(_allo);
    }

    function _handleAllocate(Allocations memory _params) internal {
        _validateV2Input(_params.poolIds, _params.amounts, _params.data);
        _transferToken(_params.token, _params.totalAmount);

        uint256 poolIdsLength = _params.poolIds.length;
        for (uint256 i = 0; i < poolIdsLength;) {
            uint256 poolId = _params.poolIds[i];
            IERC20Upgradeable(_params.token).approve(address(allo.getStrategy(poolId)), _params.amounts[i]);
            IAllo(allo).allocate(poolId, _params.data[i]);

            unchecked {
                ++i;
            }
        }
    }

    function _validateV2Input(uint256[] memory _poolIds, uint256[] memory _amounts, bytes[] memory _data)
        internal
        pure
    {
        if (_poolIds.length != _data.length || _poolIds.length != _amounts.length) {
            revert INVALID_INPUT();
        }
    }
}
