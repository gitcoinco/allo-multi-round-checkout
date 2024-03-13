// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../contracts/MultiRoundCheckout.sol";
import "../contracts/mocks/MockRoundImplementationETH.sol";

contract MrcTestVote is Test {
    MultiRoundCheckout private mrc;
    MockRoundImplementationETH private round1;
    MockRoundImplementationETH private round2;
    MockRoundImplementationETH private round3;
    address[] public rounds = new address[](3);
    bytes[][] public votes = new bytes[][](3);
    uint256[] public amounts = new uint256[](3);

    function setUp() public {
        round1 = new MockRoundImplementationETH();
        round2 = new MockRoundImplementationETH();
        round3 = new MockRoundImplementationETH();
        mrc = new MultiRoundCheckout();
        mrc.initialize();

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

        amounts[0] = 1;
        amounts[1] = 2;
        amounts[2] = 3;
    }

    function testNonReentrant() public {
        vm.deal(address(this), 10);
        MockRoundImplementationETH(rounds[0]).setReentrant(true);

        vm.expectRevert(bytes("ReentrancyGuard: reentrant call"));
        mrc.vote{value: 6}(votes, rounds, amounts);
        MockRoundImplementationETH(rounds[0]).setReentrant(false);
    }

    function testPauseVoteRevert() public {
        mrc.pause();

        vm.deal(address(this), 10 ether);

        uint256 totalValue = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalValue += amounts[i];
        }

        vm.expectRevert(bytes("Pausable: paused"));
        mrc.vote{value: totalValue}(votes, rounds, amounts);
    }

    function testVotesPassing() public {
        vm.deal(address(this), 10 ether);

        uint256 totalValue = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalValue += amounts[i];
        }

        mrc.vote{value: totalValue}(votes, rounds, amounts);

        /* Assert that votes were passed on correctly */
        for (uint256 i = 0; i < rounds.length; i++) {
            bytes[] memory receivedVotes = MockRoundImplementationETH(rounds[i]).getReceivedVotes();
            for (uint256 j = 0; j < receivedVotes.length; j++) {
                assertEq(receivedVotes[j], votes[i][j]);
            }
        }

        /* Assert that amounts were sent along correctly */
        for (uint256 i = 0; i < rounds.length; i++) {
            assertEq(address(rounds[i]).balance, amounts[i]);
        }
    }

    function testVotesLengthCheck() public {
        vm.deal(address(this), 10 ether);

        address[] memory roundsWrongLength = new address[](2);
        roundsWrongLength[0] = address(round1);
        roundsWrongLength[1] = address(round2);

        uint256 totalValue = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalValue += amounts[i];
        }

        vm.expectRevert(VotesNotEqualRoundsLength.selector);
        mrc.vote{value: totalValue}(votes, roundsWrongLength, amounts);
    }

    function testAmountsLengthCheck() public {
        vm.deal(address(this), 10 ether);

        uint256[] memory wrongAmounts = new uint256[](2);
        wrongAmounts[0] = 1;
        wrongAmounts[1] = 2;

        uint256 totalValue = 0;
        for (uint256 i = 0; i < wrongAmounts.length; i++) {
            totalValue += wrongAmounts[i];
        }

        vm.expectRevert(AmountsNotEqualRoundsLength.selector);
        mrc.vote{value: totalValue}(votes, rounds, wrongAmounts);
    }

    function testExcessAmountSent() public {
        vm.deal(address(this), 10 ether);

        uint256 totalValue = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalValue += amounts[i];
        }

        vm.expectRevert(ExcessAmountSent.selector);
        mrc.vote{value: totalValue + 1}(votes, rounds, amounts);
    }

    function testVoteDoS() public {
        vm.deal(address(this), 10 ether);

        // let's simulate another contract sent 1 ETH
        // to the MRC contract during a selfdestruct
        vm.deal(address(mrc), 1);

        uint256 totalValue = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalValue += amounts[i];
        }

        // we need to make sure that `vote` doesn't fail
        // instead of checking that the final balance is zero, MRC checks
        // that the final balance is equal to the initial one.
        mrc.vote{value: totalValue}(votes, rounds, amounts);
    }
}
