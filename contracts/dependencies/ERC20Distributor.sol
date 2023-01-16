// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Context.sol";
import "./Ownable.sol";

abstract contract ERC20Distributor is Context, ERC20, Ownable {
    // Constants
    uint128 private constant oneMonthSeconds = 2505600;
    uint128 private constant amountPerUser = 1729;
    
    uint256 public lastTimeReedem;
    uint256 public totalUsers;

    bool private newActiveUsersSet = false;

    address public claimer;
    address public oracle;
    address public hotWallet;
    address public coldWallet;

    uint256 public percentageHotWallet;

    modifier onlyClaimer () {
        require(claimer == _msgSender(), "Claimer: caller is not the claimer");
        _;
    }

    modifier onlyOracle () {
        require(oracle == _msgSender(), "Oracle: caller is not the oracle");
        _;
    }

    /**
     * @dev Emitted when distributable tokens are Claimed.
     *
     */
    event Claim(address indexed claimer, uint256 indexed timeReedem, uint256 amount);

    /**
     * @dev Emitted when active users are updated.
     *
     */
    event ActiveUsers(address indexed oracle, uint256 indexed timeUpdate, uint256 amount);

    /** @dev Set the `amount` of active users.
     *
     * Requirements:
     *
     * - `amount` cannot be zero.
     */
    function setActiveUsers(uint256 amount) public onlyOracle {
        require(amount > 0, "setActiveUsers: active users accont be 0");
        totalUsers = amount;

        newActiveUsersSet = true;
        emit ActiveUsers(_msgSender(), block.timestamp, totalUsers);
    }

    /** @dev Creates the distributable tokens and assigns them to sender account, increasing
     * the total supply.
     *
     * Emits a {Claim} event with the information of the Claim (claimer, timeRedeem and amountClaimed).
     *
     */
    function claim() public onlyClaimer {
        require(block.timestamp - lastTimeReedem >= oneMonthSeconds, "claim: not enough time has passed");
        require(newActiveUsersSet, "claim: monthly active users not updated");
        
        uint256 amountToMint = totalUsers * amountPerUser;
        uint256 amountHotWallet = amountToMint * percentageHotWallet / 10000;

        _mint(hotWallet, amountHotWallet);
        _mint(coldWallet, amountToMint - amountHotWallet);
        
        lastTimeReedem = block.timestamp;
        emit Claim(_msgSender(), lastTimeReedem, amountToMint);
    }

    function setClaimer(address _claimer) public onlyOwner {
        claimer = _claimer;
    }

    function setOracle(address _oracle) public onlyOwner {
        oracle = _oracle;
    }

    function setHotWallet(address _hotWallet) public onlyOwner {
        hotWallet = _hotWallet;
    }

    function setColdWallet(address _coldWallet) public onlyOwner {
        coldWallet = _coldWallet;
    }

    function setPercentageHotWallet(uint256 _percentageHotWallet) public onlyOwner {
        require(_percentageHotWallet <= 10000 && _percentageHotWallet >= 0, "setPercentageHotWallet: the percentage should be between 0 and 100");

        percentageHotWallet = _percentageHotWallet;
    }      
}