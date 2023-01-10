// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.4;

import "./dependences/ERC20.sol";
import "./dependences/ERC20distributor.sol";

contract ubi is ERC20, ERC20distributor {
    constructor() ERC20("Ubi", "ubi"){
    }

    function burn(uint256 amount) public{
        _burn(_msgSender(), amount);
    }
}
