// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../contracts/MultiRoundCheckout.sol";

contract MrcTest is Test {
    MultiRoundCheckout private mrc;
    MockRoundImplementation private round1;
    MockRoundImplementation private round2;
    MockRoundImplementation private round3;
    address[] public rounds = new address[](3);
    bytes[][] public votes = new bytes[][](3);
    uint256[] public values = new uint256[](3);

    function setUp() public {
        round1 = new MockRoundImplementation();
        round2 = new MockRoundImplementation();
        round3 = new MockRoundImplementation();
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

        values[0] = 1;
        values[1] = 2;
        values[2] = 3;
    }

    function testOwnership() public {
        assertEq(mrc.owner(), address(this));
    }

    function testPauseOnlyOwner() public {
        vm.prank(address(0x0));
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        mrc.pause();
    }

    function testPauseVoteRevert() public {
        mrc.pause();

        vm.deal(address(this), 10 ether);

        uint256 totalValue = 0;
        for (uint i = 0; i < values.length; i++) {
            totalValue += values[i];
        }

        vm.expectRevert(bytes("Pausable: paused"));
        mrc.vote{value: totalValue}(votes, rounds, values);
    }

    function testUnpauseOnlyOwner() public {
        vm.prank(address(0x0));
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        mrc.unpause();
    }

    function testVotesPassing() public {
        vm.deal(address(this), 10 ether);

        uint256 totalValue = 0;
        for (uint i = 0; i < values.length; i++) {
            totalValue += values[i];
        }

        mrc.vote{value: totalValue}(votes, rounds, values);

        /* Assert that votes were passed on correctly */
        for (uint i = 0; i < rounds.length; i++) {
            bytes[] memory receivedVotes = MockRoundImplementation(rounds[i])
                .getReceivedVotes();
            for (uint j = 0; j < receivedVotes.length; j++) {
                assertEq(receivedVotes[j], votes[i][j]);
            }
        }

        /* Assert that values were sent along correctly */
        for (uint i = 0; i < rounds.length; i++) {
            assertEq(address(rounds[i]).balance, values[i]);
        }
    }

    function testVotesLengthCheck() public {
        vm.deal(address(this), 10 ether);

        address[] memory roundsWrongLength = new address[](2);
        roundsWrongLength[0] = address(round1);
        roundsWrongLength[1] = address(round2);

        uint256 totalValue = 0;
        for (uint i = 0; i < values.length; i++) {
            totalValue += values[i];
        }

        vm.expectRevert(VotesNotEqualRoundsLength.selector);
        mrc.vote{value: totalValue}(votes, roundsWrongLength, values);
    }

    function testValuesLengthCheck() public {
        vm.deal(address(this), 10 ether);

        uint256[] memory wrongValues = new uint256[](2);
        wrongValues[0] = 1;
        wrongValues[1] = 2;

        uint256 totalValue = 0;
        for (uint i = 0; i < wrongValues.length; i++) {
            totalValue += wrongValues[i];
        }

        vm.expectRevert(ValuesNotEqualRoundsLength.selector);
        mrc.vote{value: totalValue}(votes, rounds, wrongValues);
    }

    function testExcessValueSent() public {
        vm.deal(address(this), 10 ether);

        uint256 totalValue = 0;
        for (uint i = 0; i < values.length; i++) {
            totalValue += values[i];
        }

        vm.expectRevert(ExcessValueSent.selector);
        mrc.vote{value: totalValue + 1}(votes, rounds, values);
    }
}

contract MockRoundImplementation is IVotable {
    bytes[] public receivedVotes;

    function vote(bytes[] memory data) external payable {
        receivedVotes = data;
    }

    function getReceivedVotes() public view returns (bytes[] memory) {
        return receivedVotes;
    }
}
