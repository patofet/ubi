// SPDX-License-Identifier: unlicensed
pragma solidity 0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.0/contracts/utils/Context.sol";
import "https://github.com/chiru-labs/ERC721A/blob/v4.1.0/contracts/ERC721A.sol";

interface IERC721ALockedTokens {

    function mintTo(address _to, uint256 _mintAmount) external ;

    function isMintable(uint256 _mintAmount) external view returns(bool);
}