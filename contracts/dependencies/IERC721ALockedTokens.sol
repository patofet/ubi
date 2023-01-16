// SPDX-License-Identifier: unlicensed
pragma solidity 0.8.17;

interface IERC721ALockedTokens {

    function mintTo(address _to, uint256 _mintAmount) external ;

    function isMintable(uint256 _mintAmount) external view returns(bool);
}