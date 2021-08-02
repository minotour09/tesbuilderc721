// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title Poly721
 * Poly721 - Base smart contract for ERC721 on Polygon
 */
contract Poly721 is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {

    mapping (string => address) private _creatorsMapping;
    mapping (uint256 => string) private _tokenIdsMapping;
    mapping (string => uint256) private _tokenIdsToHashMapping;
    address openseaProxyAddress;
    string public contract_ipfs_json;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor(
        address _openseaProxyAddress,
        string memory _name,
        string memory _ticker,
        string memory _contract_ipfs
    ) public ERC721(_name, _ticker) {
        openseaProxyAddress = _openseaProxyAddress;
        contract_ipfs_json = _contract_ipfs;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function contractURI() public view returns (string memory) {
        return contract_ipfs_json;
    }

    function totalSupply() public view returns (string memory) {
        return _tokenIdCounter.current();
    }

    function nftExists(string memory tokenHash) internal view returns (bool) {
        address owner = _creatorsMapping[tokenHash];
        return owner != address(0);
    }

    function returnTokenIdByHash(string memory tokenHash) public view returns (uint256) {
        return _tokenIdsToHashMapping[tokenHash];
    }

    function returnTokenURI(uint256 tokenId) public view returns (string memory) {
        return _tokenIdsMapping[tokenId];
    }

    function returnCreatorByNftHash(string memory hash) public view returns (address) {
        return _creatorsMapping[hash];
    }

    function canMint(string memory tokenURI) internal view returns (bool){
        require(!nftExists(tokenURI), "Poly721: Trying to mint existent nft");
        return true;
    }

    /*
        This method will first mint the token to the address.
    */
    function mintNFT(string memory tokenURI) public returns (uint256) {
        require(canMint(tokenURI), "Poly721: Can't mint token");
        uint256 tokenId = mintTo(msg.sender, tokenURI);
        _creatorsMapping[tokenURI] = msg.sender;
        _tokenIdsMapping[tokenId] = tokenURI;
        _tokenIdsToHashMapping[tokenURI] = tokenId;
        return tokenId;
    }

    /*
        Private method that mints the token
    */
    function mintTo(address _to, string memory _tokenURI) private returns (uint256){
        uint256 newTokenId = _tokenIdCounter.current();
        _mint(_to, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        _tokenIdCounter.increment();
        return newTokenId;
    }

    /*
        This method is used by OpenSea to automate the sell.
    */
    function isApprovedForAll(
        address _owner,
        address _operator
    ) public view override returns (bool isOperator) {
        if (_operator == address(openseaProxyAddress)) {
            return true;
        }
        
        return super.isApprovedForAll(_owner, _operator);
    }
}
