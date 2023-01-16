// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

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

    /**
     * @dev Throws if called by any account other than the claimer.
     */
    modifier onlyClaimer () {
        require(claimer == _msgSender(), "Claimer: caller is not the claimer");
        _;
    }

    /**
     * @dev Throws if called by any account other than the oracle.
     */
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

    /**
     * @dev Emitted when Claimer address is updated.
     *
     */
    event ClaimerChanged(address indexed previousClaimer, address indexed newClaimer);

    /**
     * @dev Emitted when Oracle address is updated.
     *
     */
    event OracleChanged(address indexed previousOracle, address indexed newOracle);

    /**
     * @dev Emitted when Hot Wallet address is updated.
     *
     */
    event HotWalletChanged(address indexed previousHotWallet, address indexed newHotWallet);

    /**
     * @dev Emitted when Cold Wallet address is updated.
     *
     */
    event ColdWalletChanged(address indexed previousColdWallet, address indexed newColdWallet);

    /**
     * @dev Emitted when Hot Wallet percentage is updated.
     *
     */
    event HotWalletPercentageChanged(uint256 previousHotWalletPercentage, uint256 newHotWalletPercentage);

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

    /** @dev Creates the distributable tokens and assigns them to the Hot and Cold wallet, increasing
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

    /** @dev Set the new Claimer address
     *
     * Emits a {ClaimerChanged} event with the address of the new and old Claimer.
     *
     */
    function setClaimer(address _claimer) public onlyOwner {
        address oldClaimer = claimer;
        claimer = _claimer;

        emit ClaimerChanged(oldClaimer, claimer);
    }

    /** @dev Set the new Oracle address
     *
     * Emits an {OracleChanged} event with the address of the new and old Oracle.
     *
     */
    function setOracle(address _oracle) public onlyOwner {
        address oldOracle = oracle;
        oracle = _oracle;

        emit OracleChanged(oldOracle, oracle);
    }

    /** @dev Set the new Hot Wallet address
     *
     * Emits a {HotWalletChanged} event with the address of the new and old Hot Wallet.
     *
     */
    function setHotWallet(address _hotWallet) public onlyOwner {
        address oldHotWallet = hotWallet;
        hotWallet = _hotWallet;

        emit HotWalletChanged(oldHotWallet, hotWallet);
    }

    /** @dev Set the new Cold Wallet address
     *
     * Emits a {ColdWalletChanged} event with the address of the new and old Cold Wallet.
     *
     */
    function setColdWallet(address _coldWallet) public onlyOwner {
        address oldColdWallet = coldWallet;
        coldWallet = _coldWallet;

        emit ColdWalletChanged(oldColdWallet, coldWallet);
    }

    /** @dev Set the new Hot Wallet Percentage
     *
     * Emits a {HotWalletPercentageChanged} event with the new and old Hot Wallet Percentage
     *
     */
    function setPercentageHotWallet(uint256 _percentageHotWallet) public onlyOwner {
        require(_percentageHotWallet <= 10000 && _percentageHotWallet >= 0, "setPercentageHotWallet: the percentage should be between 0 and 100");

        uint256 oldPercentageHotWallet = percentageHotWallet;
        percentageHotWallet = _percentageHotWallet;

        emit HotWalletPercentageChanged(oldPercentageHotWallet, percentageHotWallet);
    }      
}