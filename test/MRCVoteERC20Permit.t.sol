// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../contracts/MultiRoundCheckout.sol";
import "../contracts/mocks/MockRoundImplementationERC20.sol";
import "../contracts/mocks/MockERC20Permit.sol";
import "../contracts/mocks/SigUtils.sol";

contract MrcTestVoteERC20Permit is Test {
    MultiRoundCheckout private mrc;
    MockERC20Permit private testERC20;
    MockRoundImplementationERC20 private round1;
    MockRoundImplementationERC20 private round2;
    MockVotingStrategy private votingStrategy;
    SigUtils private sigUtils;
    address[] public rounds = new address[](2);
    bytes[][] public votes = new bytes[][](2);
    uint256[] public amounts = new uint256[](2);
    uint256 public totalAmount;
    address public project1;
    address public project2;
    address public owner;
    address public token1;
    uint256 private ownerPrivateKey;

    function setUp() public {
        votingStrategy = new MockVotingStrategy();
        round1 = new MockRoundImplementationERC20(address(votingStrategy));
        round2 = new MockRoundImplementationERC20(address(votingStrategy));
        mrc = new MultiRoundCheckout();
        testERC20 = new MockERC20Permit();
        sigUtils = new SigUtils(testERC20.DOMAIN_SEPARATOR());
        mrc.initialize();
        testERC20.initialize("Test", "TEST");
        rounds[0] = address(round1);
        rounds[1] = address(round2);

        totalAmount = 100;

        amounts[0] = 50;
        amounts[1] = 50;

        token1 = address(testERC20);

        ownerPrivateKey = 0xA11CE;
        owner = vm.addr(ownerPrivateKey);

        testERC20.mint(owner, 100);

        votes[0].push(abi.encode(address(testERC20), 25));
        votes[0].push(abi.encode(address(testERC20), 25));
        votes[1].push(abi.encode(address(testERC20), 25));
        votes[1].push(abi.encode(address(testERC20), 25));

    }

    function testPermit () public {

        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: address(mrc),
            value: 100,
            nonce: 0,
            deadline: type(uint256).max

        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        assertEq(testERC20.balanceOf(owner), 100);
        assertEq(testERC20.allowance(owner, address(mrc)), 0);

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

        assertEq(testERC20.allowance(owner, address(mrc)), 0);
        assertEq(testERC20.balanceOf(owner), 0);
        assertEq(testERC20.balanceOf(address(votingStrategy)), 100);
    }
}

