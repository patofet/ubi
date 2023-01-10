// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Context.sol";
import "./Ownable.sol";

abstract contract ERC20distributor is Context, ERC20, Ownable {
    // Constants
    uint128 private constant oneMonthSeconds = 2505600;
    uint128 private constant amountPerUser = 1729;
    
    uint256 public lastTimeReedem;
    uint256 public totalUsers;

    function setActiveUsers(uint256 amount) public virtual {
        require(amount > 0, "setActiveUsers: active users accont be 0");
        totalUsers = amount;
    }

    function claim() public virtual {
        require(block.timestamp - lastTimeReedem >= oneMonthSeconds, "claim: not enough time has passed");
        uint256 amountToMint = totalUsers * amountPerUser;
        _mint(_msgSender(), amountToMint);
        lastTimeReedem = block.timestamp;
    }

    function setUserAndClaim(uint256 amount) public onlyOwner{
        setActiveUsers(amount);
        claim();
    }
}