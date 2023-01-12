// SPDX-License-Identifier: unlicensed
pragma solidity 0.8.17;

import "./IERC721ALockedTokens.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.0/contracts/utils/Context.sol";
import "https://github.com/chiru-labs/ERC721A/blob/v4.1.0/contracts/ERC721A.sol";

contract ERC721ALockedTokens is IERC721ALockedTokens, Context, ERC721A, Ownable {

    uint256 public unlockedTokens;
    uint256 public maxSupply;

    string public baseURI;
    address public minter;

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyMinter() {
        require(minter == msg.sender, "Minter: caller is not the minter");
        _;
    }

    constructor(string memory _name, string memory _symbol, string memory _baseUri, uint256 _maxSupply, address _minter, address _owner) ERC721A(_name, _symbol) {
        baseURI = _baseUri;
        maxSupply = _maxSupply;
        minter = _minter;

        _transferOwnership(_owner);
    }

    function mintTo(address _to, uint256 _mintAmount) public override onlyMinter {
        require(isMintable(_mintAmount), "mintTo: exceed the max Supply!");

        _mintLoop(_to, _mintAmount);
    }

    function gift(address _to, uint256 _mintAmount) public onlyOwner {
        require(maxSupply >= totalSupply() + _mintAmount, "gift: exceed the max Supply!");
        _mintLoop(_to, _mintAmount);
    }

    function airdrop(address[] memory _airdropAddresses, uint256 _mintAmount) public onlyOwner {
        require(maxSupply >= totalSupply() + (_mintAmount * _airdropAddresses.length), "airdrop: exceed the max Supply!");
        for (uint256 i = 0; i < _airdropAddresses.length; i++) {
            address to = _airdropAddresses[i];
            _mintLoop(to, _mintAmount);
        }
    }

    function isMintable(uint256 _mintAmount) public override view returns(bool) {
        return maxSupply >= totalSupply() + _mintAmount;
    }

    function pauseMint() public onlyOwner {
        maxSupply = totalSupply();
    }

    function transferFrom (
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(tokenId < unlockedTokens, "transferFrom: token still not transferable");
        super.transferFrom(from, to, tokenId);
    }

    function _mintLoop(address _receiver, uint256 _mintAmount) internal {
        _safeMint(_receiver, _mintAmount);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setMaxSupply(uint256 _newMaxSupply) public onlyOwner {
        maxSupply = _newMaxSupply;        
    }

    function setUnlockedTokens(uint256 _newUnlockedTokens) public onlyOwner {
        unlockedTokens = _newUnlockedTokens;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setMinter(address _newMinter) public onlyOwner {
        minter = _newMinter;
    }
}