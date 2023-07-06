// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../contracts/MultiRoundCheckout.sol";
import "../contracts/mocks/MockRoundImplementation.sol";
import "../contracts/mocks/MockERC20Permit.sol";
import "../contracts/mocks/SigUtils.sol";

contract MrcTestVoteERC20Permit is Test {
    MultiRoundCheckout private mrc;
    MockERC20Permit private testERC20;
    MockRoundImplementation private round1;
    MockRoundImplementation private round2;
    MockRoundImplementation private round3;
    SigUtils private sigUtils;
    address[] public rounds = new address[](3);
    bytes[][] public votes = new bytes[][](3);
    uint256 public totalAmount;
    address public owner;
    address public token1;
    uint256 private ownerPrivateKey;

    function setUp() public {
        round1 = new MockRoundImplementation();
        round2 = new MockRoundImplementation();
        round3 = new MockRoundImplementation();
        mrc = new MultiRoundCheckout();
        testERC20 = new MockERC20Permit();
        sigUtils = new SigUtils(testERC20.DOMAIN_SEPARATOR());
        mrc.initialize();
        testERC20.initialize("Test", "TEST");

        rounds[0] = address(round1);
        rounds[1] = address(round2);
        rounds[2] = address(round3);

        votes[0] = new bytes[](3);
        votes[0][0] = "A";
        votes[0][1] = "B";
        votes[0][2] = "C";

        votes[1] = new bytes[](3);
        votes[1][0] = "X";
        votes[1][1] = "Y";
        votes[1][2] = "Z";

        votes[2] = new bytes[](3);
        votes[2][0] = "P";
        votes[2][1] = "Q";
        votes[2][2] = "R";

        totalAmount = 1e18;

        token1 = address(testERC20);

        ownerPrivateKey = 0xA11CE;
        owner = vm.addr(ownerPrivateKey);

        testERC20.mint(owner, 1e18);
    }

    function testPermit () public {

        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: address(mrc),
            value: 1e18,
            nonce: 0,
            deadline: type(uint256).max

        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        assertEq(testERC20.balanceOf(owner), 1e18);
        assertEq(testERC20.allowance(owner, address(mrc)), 0);

        vm.prank(owner);
        mrc.voteERC20Permit(
            votes,
            rounds,
            totalAmount,
            token1,
            v,
            r,
            s
        );

        assertEq(testERC20.allowance(owner, address(mrc)), 1e18);
    }
}

