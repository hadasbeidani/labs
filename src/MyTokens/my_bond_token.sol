// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/ERC20/ERC20.sol";
import "forge-std/console.sol";

contract MyBondToken is ERC20,onlywoner {
    constructor() ERC20("MyBondToken", "BOND") {}
}

