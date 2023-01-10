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

    /**
     * @dev Emitted when distributable tokens are Claimed.
     *
     */
    event Claim(address indexed claimer, uint256 indexed timeReedem, uint256 amount);

    /** @dev Set the `amount` of active users.
     *
     * Requirements:
     *
     * - `amount` cannot be zero.
     */
    function setActiveUsers(uint256 amount) internal virtual {
        require(amount > 0, "setActiveUsers: active users accont be 0");
        totalUsers = amount;
    }

    /** @dev Creates the distributable tokens and assigns them to sender account, increasing
     * the total supply.
     *
     * Emits a {Claim} event with the information of the Claim (claimer, timeRedeem and amountClaimed).
     *
     */
    function claim() internal virtual {
        require(block.timestamp - lastTimeReedem >= oneMonthSeconds, "claim: not enough time has passed");
        
        uint256 amountToMint = totalUsers * amountPerUser;
        _mint(_msgSender(), amountToMint);
        
        lastTimeReedem = block.timestamp;
        emit Claim(_msgSender(), lastTimeReedem, amountToMint);
    }

    /** @dev Set the `amount` of active users, creates the distributable tokens
     * and assigns them to sender account, increasing the total supply.
     *
     * Emits a {Claim} event with the information of the Claim (claimer, timeRedeem and amountClaimed).
     *
     * Requirements:
     *
     * - `amount` cannot be zero.
     * - the caller of the function must be the owner of the Smart Contract.
     */
    function setUserAndClaim(uint256 amount) public onlyOwner{
        setActiveUsers(amount);
        claim();
    }
}