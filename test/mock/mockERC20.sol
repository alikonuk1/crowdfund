// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function mint(uint256 amount) public {
        _mint(msg.sender, amount);
    }
}
