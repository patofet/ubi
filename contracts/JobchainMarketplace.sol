// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.4;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.0/contracts/utils/Context.sol";
import "./dependencies/ERC721ALockedTokens.sol";
import "./dependencies/IERC20.sol";

contract JobchainMarketplace is Context, Ownable {

    mapping(address => bool) public isCollection;
    mapping(address => bool) public isAllowedToCreate;
    mapping(address => mapping(uint256 => uint256)) public pricesPerQuality;
    IERC20 ubi;

    event CollectionCreated(address indexed collection, address indexed owner);
    event Buy(address indexed collection, address indexed quality, address buyer, uint256 amount);

    constructor (address _ubi) {
        ubi = IERC20(_ubi);
    }

    function createCollection(string memory _name, string memory _symbol, string memory _baseUri, uint256 _maxSupply) public {
        require(isAllowedToCreate[_msgSender()], "createCollection: the address is not allowed to create collections");        
        ERC721ALockedTokens collection = new ERC721ALockedTokens(_name, _symbol, _baseUri, _maxSupply, address(this));       

        isCollection[address(collection)] = true;
    }

    function buyNFT(address _collection, uint256 _quality, uint256 _amount) public {
        require(isCollection[_collection], "buyNFT: the `_collection` address is not a collection");
        require(ERC721ALockedTokens(_collection).isMintable(_amount), "buyNFT: the mint is not available");
        require(pricesPerQuality[_collection][_quality] * _amount < ubi.balanceOf(_msgSender()), "buyNFT: the address does not have enough balance");
        require(pricesPerQuality[_collection][_quality] * _amount < ubi.allowance(_msgSender(), address(this)), "buyNFT: must increase spending allowance");

        ubi.transferFrom(_msgSender(), _collection, pricesPerQuality[_collection][_quality] * _amount);
        ERC721ALockedTokens(_collection).mintTo(_msgSender(), _amount);
    }

    function setCollectionPrices(address _collection, uint256[] memory _qualities, uint256[] memory _prices) public {
        require(isCollection[_collection], "setCollectionPrices: the `_collection` address is not a collection");
        require(_msgSender() == ERC721ALockedTokens(_collection).owner(), "setCollectionPrices: you must be the owner of the collection");
        require(_qualities.length == _prices.length, "setCollectionPrices: `_qualities` and `_prices` must be the same length");

        for(uint64 i = 0; i < _qualities.length; i++) {
            pricesPerQuality[_collection][_qualities[i]] = _prices[i];
        }
    }

    function toggleCreators(address[] memory _creator) public onlyOwner {
        for(uint256 i = 0; i < _creator.length; i++) {
            isAllowedToCreate[_creator[i]] = !isAllowedToCreate[_creator[i]];
        }
    }
}