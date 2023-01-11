// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Context.sol";
import "./Ownable.sol";

abstract contract ERC20UserDistributor is Context, ERC20, Ownable {
    // Constants
    uint128 private constant oneMonthSeconds = 2592000;
    uint128 private constant oneDay = 86400;
    uint128 private constant amountPerUser = 1729;
    
    mapping(address => uint256) public lastTimeReedem;

    /**
     * @dev Emitted when distributable tokens are Claimed.
     *
     */
    event Claim(address indexed claimer, uint256 indexed timeReedem, uint256 amount);
    /**
     * @dev Emitted when the user registers.
     *
     */
    event Register(address indexed user, uint256 indexed timeRegistered);

    /** @dev Registers the user in order to allow to claim tokens.
     *
     * Emits a {Register} event with the information of the User (user, timeRegistered).
     *
     */
    function register(address user) public onlyOwner {
        require(lastTimeReedem[user] == 0, "claim: user already registered");

        lastTimeReedem[user] = block.timestamp;
        emit Register(_msgSender(), block.timestamp);
    }

    /** @dev Creates the distributable tokens and assigns them to sender account, increasing
     * the total supply.
     *
     * Emits a {Claim} event with the information of the Claim (claimer, timeRedeem and amountClaimed).
     *
     */
    function claim() public {
        require(lastTimeReedem[_msgSender()] != 0, "claim: user not registered");
        require(block.timestamp - lastTimeReedem[_msgSender()] >= oneMonthSeconds - oneDay, "claim: not enough time has passed");
        uint256 amount = amountPerUser * ((block.timestamp - lastTimeReedem[_msgSender()])/oneMonthSeconds);
        _mint(_msgSender(), amount);
        
        lastTimeReedem[_msgSender()] = block.timestamp;
        emit Claim(_msgSender(), lastTimeReedem[_msgSender()], amount);
    }
}