pragma solidity ^0.8.0;

contract ERC20Upgradeable {
    mapping(address => uint256) private lastTimeReedem;
    uint256 private constant oneMonthSeconds = 2630000;
    uint256 public totalUsers;

    function setActiveUsers(uint256 amount) public virtual {
        require(amount > 0, "setActiveUsers: active users accont be 0");
        totalUsers = amount;
    }

    function registerUser() public virtual{
        require(lastTimeReedem[msg.sender] == 0, "registerUser: user already registered");
        lastTimeReedem[msg.sender] = block.timestamp;
    }

    function claim() public virtual{
        require(lastTimeReedem[msg.sender] - block.timestamp >= oneMonthSeconds, "claim: user can't claim because not enough time has passed");
        lastTimeReedem[msg.sender] = block.timestamp;
    }
}