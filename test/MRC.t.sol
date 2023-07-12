// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../contracts/MultiRoundCheckout.sol";

contract MrcTestVote is Test {
    MultiRoundCheckout private mrc;

    function setUp() public {
        mrc = new MultiRoundCheckout();
        mrc.initialize();
    }

    function testOwnership() public {
        assertEq(mrc.owner(), address(this));
    }

    function testPauseOnlyOwner() public {
        vm.prank(address(0x0));
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        mrc.pause();
    }

    function testUnpauseOnlyOwner() public {
        vm.prank(address(0x0));
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        mrc.unpause();
    }

}

