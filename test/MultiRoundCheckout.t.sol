// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../contracts/MultiRoundCheckout.sol";
import "../allo-contracts/contracts/votingStrategy/QuadraticFundingStrategy/QuadraticFundingVotingStrategyFactory.sol";
import "../allo-contracts/contracts/payoutStrategy/MerklePayoutStrategy/MerklePayoutStrategyFactory.sol";
import "../allo-contracts/contracts/round/RoundFactory.sol";

contract ContractBTest is Test {
    MultiRoundCheckout private mrc;
    RoundImplementation private round1;
    RoundImplementation private round2;
    RoundImplementation private round3;

    struct InitAddress {
        IVotingStrategy votingStrategy; // Deployed voting strategy contract
        IPayoutStrategy payoutStrategy; // Deployed payout strategy contract
    }

    struct InitRoundTime {
        uint256 applicationsStartTime; // Unix timestamp from when round can accept applications
        uint256 applicationsEndTime; // Unix timestamp from when round stops accepting applications
        uint256 roundStartTime; // Unix timestamp of the start of the round
        uint256 roundEndTime; // Unix timestamp of the end of the round
    }

    struct InitMetaPtr {
        MetaPtr roundMetaPtr; // MetaPtr to the round metadata
        MetaPtr applicationMetaPtr; // MetaPtr to the application form schema
    }

    struct InitRoles {
        address[] adminRoles; // Addresses to be granted DEFAULT_ADMIN_ROLE
        address[] roundOperators; // Addresses to be granted ROUND_OPERATOR_ROLE
    }

    function setUp() public {
        mrc = new MultiRoundCheckout();

        QuadraticFundingVotingStrategyFactory qfVotingStrategyFactory = new QuadraticFundingVotingStrategyFactory();
        qfVotingStrategyFactory.initialize();

        QuadraticFundingVotingStrategyImplementation qfVotingStratImpl = new QuadraticFundingVotingStrategyImplementation();
        qfVotingStratImpl.initialize();

        qfVotingStrategyFactory.updateVotingContract(
            address(qfVotingStratImpl)
        );

        MerklePayoutStrategyFactory merkleFactory = new MerklePayoutStrategyFactory();
        merkleFactory.initialize();

        MerklePayoutStrategyImplementation merkleImpl = new MerklePayoutStrategyImplementation();
        merkleImpl.initialize();

        merkleFactory.updatePayoutImplementation(payable(merkleImpl));

        AlloSettings settings = new AlloSettings();
        settings.initialize();

        RoundFactory roundFactory = new RoundFactory();
        roundFactory.initialize();

        RoundImplementation roundImpl = new RoundImplementation();

        roundFactory.updateRoundImplementation(payable(roundImpl));
        roundFactory.updateAlloSettings(address(settings));

        bytes memory params = generateAndEncodeRoundParam(
            address(qfVotingStratImpl),
            payable(merkleImpl),
            msg.sender
        );

        roundFactory.create(params, msg.sender);
    }

    function generateAndEncodeRoundParam(
        address votingContract,
        address payable payoutContract,
        address adminAddress
    ) public view returns (bytes memory) {
        uint256 currentTimestamp = block.timestamp;
        MetaPtr memory roundMetaPtr = MetaPtr(
            1,
            "bafybeia4khbew3r2mkflyn7nzlvfzcb3qpfeftz5ivpzfwn77ollj47gqi"
        );
        MetaPtr memory applicationMetaPtr = MetaPtr(
            1,
            "bafkreih3mbwctlrnimkiizqvu3zu3blszn5uylqts22yvsrdh5y2kbxaia"
        );
        address[] memory roles = new address[](1);
        roles[0] = adminAddress;
        uint256 matchAmount = 100;
        address token = address(0);
        uint32 roundFeePercentage = 0;
        address roundFeeAddress = address(0);
        InitAddress memory initAddress = InitAddress(
            QuadraticFundingVotingStrategyImplementation(votingContract),
            MerklePayoutStrategyImplementation(payoutContract)
        );
        uint256 SECONDS_PER_SLOT = 15; // Goerli slot time
        InitRoundTime memory initRoundTime = InitRoundTime(
            currentTimestamp, // Applications start
            currentTimestamp + 60, // Applications End
            currentTimestamp, // Voting Starts
            currentTimestamp + 120 // Voting Ends
        );
        InitMetaPtr memory initMetaPtr = InitMetaPtr(
            roundMetaPtr,
            applicationMetaPtr
        );
        InitRoles memory initRoles = InitRoles(roles, roles);

        return
            abi.encode(
            initAddress,
            initRoundTime,
            matchAmount,
            token,
            roundFeePercentage,
            roundFeeAddress,
            initMetaPtr,
            initRoles
        );
    }
}