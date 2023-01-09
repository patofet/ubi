// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.4;

import "./dependences/ERC20Upgradeable.sol";
import "./dependences/ERC20BurnableUpgradeable.sol";
import "./dependences/OwnableUpgradeable.sol";
import "./dependences/Initializable.sol";

contract ubi is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, OwnableUpgradeable {
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __ERC20_init("Ubi", "ubi");
        __ERC20Burnable_init();
        __Ownable_init();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
