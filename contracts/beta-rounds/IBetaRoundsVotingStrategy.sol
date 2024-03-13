// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.17;

/**
 * @notice Defines the abstract contract for voting algorithms on grants
 * within a round. Any new voting algorithm would be expected to
 * extend this abstract contract.
 * Every IVotingStrategy contract would be unique to RoundImplementation
 * and would be deployed before creating a round
 */
abstract contract IVotingStrategy {
    // voting amount
    // voter address
    // grant address
    // project id
    // application index
    // round address
    event Voted( // voting token
        address token,
        uint256 amount,
        address indexed voter,
        address grantAddress,
        bytes32 indexed projectId,
        uint256 applicationIndex,
        address indexed roundAddress
    );

    // --- Data ---

    /// @notice Round address
    address public roundAddress;

    // --- Modifier ---

    /// @notice modifier to check if sender is round contract.
    modifier isRoundContract() {
        require(roundAddress != address(0), "error: voting contract not linked to a round");
        require(msg.sender == roundAddress, "error: can be invoked only by round contract");
        _;
    }

    // --- Core methods ---

    /**
     * @notice Invoked by RoundImplementation on creation to
     * set the round for which the voting contracts is to be used
     *
     */
    function init() external {
        require(roundAddress == address(0), "init: roundAddress already set");
        roundAddress = msg.sender;
    }

    /**
     * @notice Invoked by RoundImplementation to allow voter to case
     * vote for grants during a round.
     *
     * @dev
     * - allows contributor to do cast multiple votes which could be weighted.
     * - should be invoked by RoundImplementation contract
     * - ideally IVotingStrategy implementation should emit events after a vote is cast
     * - this would be triggered when a voter casts their vote via grant explorer
     *
     * @param _encodedVotes encoded votes
     * @param _voterAddress voter address
     */
    function vote(bytes[] calldata _encodedVotes, address _voterAddress) external payable virtual;
}
