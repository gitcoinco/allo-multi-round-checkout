// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.17;

abstract contract IAllo {
    function getStrategy(uint256 _poolId) external view virtual returns (address);
    function allocate(uint256 _poolId, bytes memory _data) external payable virtual;
}
