// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../contracts/MultiRoundCheckout.sol";
import "../contracts/mocks/MockRoundImplementationDAI.sol";
import "../contracts/mocks/MockVotingStrategy.sol";
import "../contracts/mocks/MockDAIPermit.sol";
import "../contracts/mocks/SigUtils.sol";

contract MrcTestVoteDAIPermit is Test {
    MultiRoundCheckout private mrc;
    MockDAIPermit private testDAI;
    MockRoundImplementationDAI private round1;
    MockRoundImplementationDAI private round2;
    MockRoundImplementationDAI private round3;
    MockVotingStrategy private votingStrategy;
    SigUtils private sigUtils;
    SigUtils.Permit private permit;
    bytes32 private digest;
    uint8 private v;
    bytes32 private r;
    bytes32 private s;
    address[] public rounds = new address[](2);
    bytes[][] public votes = new bytes[][](2);
    uint256[] public amounts = new uint256[](2);
    uint256 public totalAmount;
    address public project1;
    address public project2;
    address public owner;
    address public token1;
    uint256 private ownerPrivateKey;
    uint256 private chainId;

    function setUp() public {
        votingStrategy = new MockVotingStrategy();
        round1 = new MockRoundImplementationDAI(address(votingStrategy));
        round2 = new MockRoundImplementationDAI(address(votingStrategy));
        round3 = new MockRoundImplementationDAI(address(votingStrategy));
        mrc = new MultiRoundCheckout();
        chainId = 1;
        testDAI = new MockDAIPermit(chainId);

        sigUtils = new SigUtils(testDAI.DOMAIN_SEPARATOR());

        mrc.initialize();
        rounds[0] = address(round1);
        rounds[1] = address(round2);

        totalAmount = 100;

        amounts[0] = 50;
        amounts[1] = 50;

        token1 = address(testDAI);

        ownerPrivateKey = 0xA11CE;
        owner = vm.addr(ownerPrivateKey);

        testDAI.mint(owner, 100);

        votes[0].push(abi.encode(address(testDAI), 25));
        votes[0].push(abi.encode(address(testDAI), 25));
        votes[1].push(abi.encode(address(testDAI), 25));
        votes[1].push(abi.encode(address(testDAI), 25));
        
        permit = SigUtils.Permit({
            owner: owner,
            spender: address(mrc),
            value: 100,
            nonce: 0,
            deadline: type(uint256).max

        });

        digest = sigUtils.getTypedDataHash(permit);

        (v, r, s) = vm.sign(ownerPrivateKey, digest);

    }

    function testVoteDAIPermit() public {
        assertEq(testDAI.balanceOf(owner), 100);
        assertEq(testDAI.allowance(owner, address(mrc)), 0);

        vm.prank(owner);
        mrc.voteERC20Permit(
            votes,
            rounds,
            amounts,
            totalAmount,
            token1,
            v,
            r,
            s
        );

        assertEq(testDAI.allowance(owner, address(mrc)), 0);
        assertEq(testDAI.balanceOf(owner), 0);
        assertEq(testDAI.balanceOf(address(votingStrategy)), 100);
    }

    function testNonReentrant() public {
        MockRoundImplementationDAI(rounds[0]).setReentrant(true);

        vm.expectRevert(bytes("ReentrancyGuard: reentrant call"));
        vm.prank(owner);
        mrc.voteERC20Permit(
            votes,
            rounds,
            amounts,
            totalAmount,
            token1,
            v,
            r,
            s
        );
        MockRoundImplementationDAI(rounds[0]).setReentrant(false);
    }

    function testPauseVoteRevert() public {
        mrc.pause();

        vm.expectRevert(bytes("Pausable: paused"));
        vm.prank(owner);
        mrc.voteERC20Permit(
            votes,
            rounds,
            amounts,
            totalAmount,
            token1,
            v,
            r,
            s
        );
    }

    function testVotesLengthCheck() public {
        address[] memory roundsWrongLength = new address[](3);
        roundsWrongLength[0] = address(round1);
        roundsWrongLength[1] = address(round2);
        roundsWrongLength[2] = address(round3);

        vm.expectRevert(VotesNotEqualRoundsLength.selector);
         mrc.voteERC20Permit(
            votes,
            roundsWrongLength,
            amounts,
            totalAmount,
            token1,
            v,
            r,
            s
        );
    }

    function testAmountsLengthCheck() public {
        uint256[] memory wrongAmounts = new uint256[](3);
        wrongAmounts[0] = 1;
        wrongAmounts[1] = 2;
        wrongAmounts[2] = 3;

        vm.expectRevert(AmountsNotEqualRoundsLength.selector);
         mrc.voteERC20Permit(
            votes,
            rounds,
            wrongAmounts,
            totalAmount,
            token1,
            v,
            r,
            s
        );
    }

    function testExcessAmountSent() public {
        uint256 ownerPrivateKey2 = 0xA11CF;
        address owner2 = vm.addr(ownerPrivateKey2);
        uint256 totalAmount2 = 110;

        testDAI.mint(owner2, 110);

        SigUtils.Permit memory permit2 = SigUtils.Permit({
            owner: owner2,
            spender: address(mrc),
            value: 110,
            nonce: 0,
            deadline: type(uint256).max

        });

        bytes32 digest2 = sigUtils.getTypedDataHash(permit2);

        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(ownerPrivateKey2, digest2);

        vm.prank(owner2);
        vm.expectRevert(ExcessAmountSent.selector);
        mrc.voteERC20Permit(
            votes,
            rounds,
            amounts,
            totalAmount2,
            token1,
            v2,
            r2,
            s2
        );
    }

    function testPermitAlreadyExistsAndVoteERC20PermitDoesNotRevert() public {
        vm.prank(owner);
        MockERC20Permit(address(testDAI)).permit(owner, address(mrc), 100, type(uint256).max, v, r, s);

        // invalid permit with wrong value and nonce
        SigUtils.Permit memory permit3 = SigUtils.Permit({
            owner: owner,
            spender: address(mrc),
            value: 10,
            nonce: 5,
            deadline: type(uint256).max

        });

        bytes32 digest3 = sigUtils.getTypedDataHash(permit3);

        (uint8 v3, bytes32 r3, bytes32 s3) = vm.sign(ownerPrivateKey, digest3);

        vm.prank(owner);
        mrc.voteERC20Permit(
            votes,
            rounds,
            amounts,
            totalAmount,
            token1,
            v3,
            r3,
            s3
        );

        assertEq(testDAI.balanceOf(owner), 0);
        assertEq(testDAI.balanceOf(address(votingStrategy)), 100);
    }

    function testPermitDoesNotExistAndVoteERC20PermitReverts() public {
        // invalid permit with wrong nonce
        SigUtils.Permit memory permit3 = SigUtils.Permit({
            owner: owner,
            spender: address(mrc),
            value: 100,
            nonce: 5,
            deadline: type(uint256).max

        });

        bytes32 digest3 = sigUtils.getTypedDataHash(permit3);

        (uint8 v3, bytes32 r3, bytes32 s3) = vm.sign(ownerPrivateKey, digest3);

        vm.expectRevert("ERC20Permit: invalid signature");
        vm.prank(owner);
        mrc.voteERC20Permit(
            votes,
            rounds,
            amounts,
            totalAmount,
            token1,
            v3,
            r3,
            s3
        );
    }

}

