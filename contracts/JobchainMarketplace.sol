// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./dependencies/ERC721ALockedTokens.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract JobchainMarketplace is Context, Ownable {

    mapping(address => bool) public isCollection;
    mapping(address => bool) public isAllowedToCreate;
    mapping(address => mapping(uint256 => uint256)) public pricesPerQuality;
    IERC20 ubi;

    event Creation(address indexed collection, address indexed owner);
    event Buy(address indexed collection, uint256 indexed quality, uint256 amount, address buyer);
    event PricesUpdate(address indexed collection, uint256[] qualities, uint256[] prices);
    event Acceptance(address[] creators);

    constructor (address _ubi) {
        ubi = IERC20(_ubi);
    }

    function createCollection(string memory _name, string memory _symbol, string memory _baseUri, uint256 _maxSupply) public {
        require(isAllowedToCreate[_msgSender()], "createCollection: the address is not allowed to create collections");        
        ERC721ALockedTokens collection = new ERC721ALockedTokens(_name, _symbol, _baseUri, _maxSupply, address(this), _msgSender());       

        isCollection[address(collection)] = true;
        emit Creation(address(collection), _msgSender());
    }

    function buyNFT(address _collection, uint256 _quality, uint256 _amount) public {
        require(isCollection[_collection], "buyNFT: the `_collection` address is not a collection");
        require(ERC721ALockedTokens(_collection).isMintable(_amount), "buyNFT: the mint is not available");
        require(pricesPerQuality[_collection][_quality] * _amount < ubi.balanceOf(_msgSender()), "buyNFT: the address does not have enough balance");
        require(pricesPerQuality[_collection][_quality] * _amount < ubi.allowance(_msgSender(), address(this)), "buyNFT: must increase spending allowance");

        ubi.transferFrom(_msgSender(), _collection, pricesPerQuality[_collection][_quality] * _amount);
        ERC721ALockedTokens(_collection).mintTo(_msgSender(), _amount);

        emit Buy(_collection, _quality, _amount, _msgSender());
    }

    function setCollectionPrices(address _collection, uint256[] memory _qualities, uint256[] memory _prices) public {
        require(isCollection[_collection], "setCollectionPrices: the `_collection` address is not a collection");
        require(_msgSender() == ERC721ALockedTokens(_collection).owner(), "setCollectionPrices: you must be the owner of the collection");
        require(_qualities.length == _prices.length, "setCollectionPrices: `_qualities` and `_prices` must be the same length");

        for(uint256 i = 0; i < _qualities.length; i++) {
            pricesPerQuality[_collection][_qualities[i]] = _prices[i];
        }

        emit PricesUpdate(_collection, _qualities, _prices);
    }

    function toggleCreators(address[] memory _creators) public onlyOwner {
        for(uint256 i = 0; i < _creators.length; i++) {
            isAllowedToCreate[_creators[i]] = !isAllowedToCreate[_creators[i]];
        }

        emit Acceptance(_creators);
    }
}