// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../contracts/MultiRoundCheckout.sol";

contract MrcTest is Test {
    MultiRoundCheckout private mrc;
    MockRoundImplementation private round1;
    MockRoundImplementation private round2;
    MockRoundImplementation private round3;

    function setUp() public {
        round1 = new MockRoundImplementation();
        round2 = new MockRoundImplementation();
        round3 = new MockRoundImplementation();
        mrc = new MultiRoundCheckout();
    }

    function testVotesPassing() public {
        address[] memory rounds = new address[](3);
        rounds[0] = address(round1);
        rounds[1] = address(round2);
        rounds[2] = address(round3);

        bytes[][] memory votes = new bytes[][](3);

        votes[0] = new bytes[](3);
        votes[0][0] = "A";
        votes[0][1] = "B";
        votes[0][2] = "C";

        votes[1] = new bytes[](3);
        votes[1][0] = "A";
        votes[1][1] = "B";
        votes[1][2] = "C";

        votes[2] = new bytes[](3);
        votes[2][0] = "A";
        votes[2][1] = "B";
        votes[2][2] = "C";

        mrc.vote(votes, rounds);

        for (uint i = 0; i < rounds.length; i++) {
            bytes[] memory receivedVotes = MockRoundImplementation(rounds[i]).getReceivedVotes();
            for (uint j = 0; j < receivedVotes.length; j++) {
                assertEq(receivedVotes[j],votes[i][j]);
            }
        }
    }
}

contract MockRoundImplementation is IRoundImplementation {
    bytes[] public receivedVotes;

    function vote(bytes[] memory data) external payable {
        receivedVotes = data;
    }

    function getReceivedVotes() public view returns (bytes[] memory) {
        return receivedVotes;
    }
}