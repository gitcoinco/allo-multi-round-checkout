// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";

contract MockERC20PermitUpgradeable is ERC20Upgradeable, ERC20PermitUpgradeable {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply
    ) ERC20Upgradeable(name_, symbol_) {
        _mint(msg.sender, initialSupply);
    }
}
