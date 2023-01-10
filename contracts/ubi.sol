// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.4;

import "./dependencies/ERC20.sol";
import "./dependencies/ERC20distributor.sol";

contract ubi is ERC20, ERC20distributor {
    constructor() ERC20("Ubi", "ubi"){
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function burn(uint256 amount) public{
        _burn(_msgSender(), amount);
    }
}
