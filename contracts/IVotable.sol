// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.17;

interface IVotable {
    function vote(bytes[] memory data) external payable;
}