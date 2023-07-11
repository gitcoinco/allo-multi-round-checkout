// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../contracts/MultiRoundCheckout.sol";
import "../contracts/mocks/MockRoundImplementationDAI.sol";
import "../contracts/mocks/MockVotingStrategy.sol";
import "../contracts/mocks/MockDAIPermit.sol";
import "../contracts/mocks/SigUtilsDAI.sol";

contract MrcTestVoteDAIPermit is Test {
    MultiRoundCheckout private mrc;
    MockDAIPermit private testDAI;
    MockRoundImplementationDAI private round1;
    MockRoundImplementationDAI private round2;
    MockRoundImplementationDAI private round3;
    MockVotingStrategy private votingStrategy;
    SigUtilsDAI private sigUtilsDAI;
    SigUtilsDAI.Permit private permit;
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
    uint256 private nonce;

    function setUp() public {
        votingStrategy = new MockVotingStrategy();
        round1 = new MockRoundImplementationDAI(address(votingStrategy));
        round2 = new MockRoundImplementationDAI(address(votingStrategy));
        round3 = new MockRoundImplementationDAI(address(votingStrategy));
        mrc = new MultiRoundCheckout();
        chainId = 1;
        nonce = 0;
        testDAI = new MockDAIPermit(chainId);

        sigUtilsDAI = new SigUtilsDAI(testDAI.DOMAIN_SEPARATOR());

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
        
        permit = SigUtilsDAI.Permit({
            holder: owner,
            spender: address(mrc),
            nonce: nonce,
            expiry: type(uint256).max,
            allowed: true
        });

        digest = sigUtilsDAI.getTypedDataHash(permit);

        (v, r, s) = vm.sign(ownerPrivateKey, digest);

    }

    function testVoteDAIPermit() public {
        assertEq(testDAI.balanceOf(owner), 100);
        assertEq(testDAI.allowance(owner, address(mrc)), 0);

        vm.prank(owner);
        mrc.voteDAIPermit(
            votes,
            rounds,
            amounts,
            totalAmount,
            token1,
            nonce,
            v,
            r,
            s
        );

        assertEq(testDAI.balanceOf(owner), 0);
        assertEq(testDAI.balanceOf(address(votingStrategy)), 100);
    }

    function testNonReentrant() public {
        MockRoundImplementationDAI(rounds[0]).setReentrant(true);

        vm.expectRevert(bytes("ReentrancyGuard: reentrant call"));
        vm.prank(owner);
        mrc.voteDAIPermit(
            votes,
            rounds,
            amounts,
            totalAmount,
            token1,
            nonce,
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
        mrc.voteDAIPermit(
            votes,
            rounds,
            amounts,
            totalAmount,
            token1,
            nonce,
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
        mrc.voteDAIPermit(
            votes,
            roundsWrongLength,
            amounts,
            totalAmount,
            token1,
            nonce,
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
        mrc.voteDAIPermit(
            votes,
            rounds,
            wrongAmounts,
            totalAmount,
            token1,
            nonce,
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

        SigUtilsDAI.Permit memory permit2 = SigUtilsDAI.Permit({
            holder: owner2,
            spender: address(mrc),
            nonce: nonce,
            expiry: type(uint256).max,
            allowed: true
        });

        bytes32 digest2 = sigUtilsDAI.getTypedDataHash(permit2);

        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(ownerPrivateKey2, digest2);

        vm.prank(owner2);
        vm.expectRevert(ExcessAmountSent.selector);
        mrc.voteDAIPermit(
            votes,
            rounds,
            amounts,
            totalAmount2,
            token1,
            nonce,
            v2,
            r2,
            s2
        );
    }

    function testPermitAlreadyExistsAndVoteDAIPermitDoesNotRevert() public {
        vm.prank(owner);
        MockDAIPermit(address(testDAI)).permit(owner, address(mrc), nonce, type(uint256).max, true, v, r, s);

        // invalid permit with wrong nonce
        SigUtilsDAI.Permit memory permit3 = SigUtilsDAI.Permit({
            holder: owner,
            spender: address(mrc),
            nonce: 5,
            expiry: type(uint256).max,
            allowed: true
        });

        bytes32 digest3 = sigUtilsDAI.getTypedDataHash(permit3);

        (uint8 v3, bytes32 r3, bytes32 s3) = vm.sign(ownerPrivateKey, digest3);

        vm.prank(owner);
        mrc.voteDAIPermit(
            votes,
            rounds,
            amounts,
            totalAmount,
            token1,
            nonce,
            v3,
            r3,
            s3
        );

        assertEq(testDAI.balanceOf(owner), 0);
        assertEq(testDAI.balanceOf(address(votingStrategy)), 100);
    }

    function testPermitDoesNotExistAndVoteDAIPermitReverts() public {
        // invalid permit with wrong nonce
        SigUtilsDAI.Permit memory permit3 = SigUtilsDAI.Permit({
            holder: owner,
            spender: address(mrc),
            nonce: 5,
            expiry: type(uint256).max,
            allowed: true
        });

        bytes32 digest3 = sigUtilsDAI.getTypedDataHash(permit3);

        (uint8 v3, bytes32 r3, bytes32 s3) = vm.sign(ownerPrivateKey, digest3);

        vm.expectRevert("Dai/invalid-permit");
        vm.prank(owner);
         mrc.voteDAIPermit(
            votes,
            rounds,
            amounts,
            totalAmount,
            token1,
            nonce,
            v3,
            r3,
            s3
        );
    }

}

