//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
/**
 * @title IERC2981
 * @dev Interface for the ERC2981: NFT Royalty Standard extension, which extends the ERC721 standard.
 */
interface IERC2981 is IERC165 {

  /**
   * @notice Called with the sale price to determine how much royalty is owed and to whom.
   * @param _tokenId - The ID of the NFT asset queried for royalty information.
   * @param _salePrice - The sale price of the NFT asset specified by _tokenId.
   * @return receiver - Address of who should be sent the royalty payment.
   * @return royaltyAmount - The royalty payment amount for _salePrice.
   */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view
        returns (address receiver, uint256 royaltyAmount);
} 

contract FARPGartifacts is IERC2981, ERC1155, Ownable {

    constructor() ERC1155("") {
     
    }
     
    string public name = "FantomAdventureRPG Artifact";
    string public symbol = "aFARPG";
    uint16 private constant MAX_MINTABLE = 9999;
    // A struct to hold the Artifact's effects, keep it simple as it needed by master contract
    struct ArtifactsEffects {
        uint16 id;         // The unique ID of the Pet, used to track the same token
        uint32 A;   // HP +
        uint32 B;  // STR +
        uint32 C;   // AGI +
        uint32 D;   // INT +
        uint16 R; // rarity 0 = gold, 1 = common, 2 = rare, 3 = mystical
    }
    struct ArtifactsMetadata {
        string name;   // The name of the artifact
        string description;   // The unique ID of the Pet, used to track the same token
        string ipfs;   // should be ipfs folder, e.g. SDF4DW12ER123EFASFG234/ , remember the '/' at the end
        uint32 timestamp; //release date/item discovered
    }
    string public constant baseUri = "ipfs://";
    string public imageExtension = ".jpg";
    ArtifactsEffects[MAX_MINTABLE] public ArEf;
    ArtifactsMetadata[MAX_MINTABLE] public ArMe;

    uint public royalty; // base 10000, 750 royalty means 7.5%
    address public royaltyRecipient;

    function royaltyInfo(uint256, uint256 _salePrice)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        uint256 amount = (_salePrice * royalty) / 10000;
        return (royaltyRecipient, amount);
    }

    function supportsInterface(bytes4 interfaceId) public view override(IERC165, ERC1155) returns (bool) {
        if (royalty == 0) {
        return super.supportsInterface(interfaceId);
        }
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    function setRoyaltyRecipient(address _royaltyRecipient) external onlyOwner {
        require(_royaltyRecipient != address(0), "royalty cannot be sent to zero address");
        royaltyRecipient = _royaltyRecipient;
    }

   
    event MaxMintsReached();
    event UpdateName(string name);
    event Ignore(bool ignore);

    
    using Counters for Counters.Counter;
    Counters.Counter public tokenIds;
    using Strings for uint256;

    // Master contract, that can reward players from this reward.
    address internal mastercontract;
    // The fee for minting
    uint public MINTFEE;
    
    // Maximum number of individual nft tokenIds that can be created
    uint128 public maxMints;
    mapping(uint256 => string) internal tokenURIs;
    

    

    function uri(uint256 _tokenId) public view virtual override returns (string memory) {

        // If there is no base URI, return the token URI.
        if (bytes(baseUri).length == 0) {
        return tokenURIs[_tokenId];
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(tokenURIs[_tokenId]).length > 0) {
        return string(abi.encodePacked(baseUri, _tokenId, imageExtension));
        }

        return super.uri(_tokenId);
    }

    function batchMint(
        address _to,
        uint256[] memory _amounts,
        ArtifactsEffects[] memory _effects,
        ArtifactsMetadata[] memory _metadata
    ) external payable onlyOwner {
        require((_amounts.length == _effects.length) && _amounts.length == _metadata.length); //make sure the array size are matched
        require(msg.value == MINTFEE * _amounts.length, "Not enough ftm");

        uint[] memory ids = new uint[](_amounts.length);
        for (uint i = 0; i < _amounts.length; ++i) {
            tokenIds.increment();
            uint256 id = tokenIds.current();
            ids[i] = id;
            ArEf[id] = _effects[id];
            ArMe[id] = _metadata[id]; //date of release cannot be editted. that is the uniqueness and value of NFT
            ArMe[id].timestamp = uint32(block.timestamp);
        }

        require(tokenIds.current() <= maxMints);
        if (tokenIds.current() == maxMints) {
        emit MaxMintsReached();
        }

        _mintBatch(_to, ids, _amounts, "");

 
    }

    // The uri must be in the form of ipfs:// where the ipfs:// prefix has been stripped
    function mint(
        address _to,
        uint _amount, //want to fix an amount, gold?100m artifact?10k
        ArtifactsEffects memory _effects,
        ArtifactsMetadata memory _metadata
    ) external payable onlyOwner {
        require(msg.value == MINTFEE, "Not enough ftm");
        tokenIds.increment();
        uint256 id = tokenIds.current();
        _mint(_to, id, _amount, ""); //give ownership to ID
        ArEf[id] = _effects;
        ArMe[id] = _metadata; //date of release cannot be editted. that is the uniqueness and value of NFT
        ArMe[id].timestamp = uint32(block.timestamp);
        require(tokenIds.current() <= maxMints);
        if (tokenIds.current() == maxMints) {
        emit MaxMintsReached();
        }

    }

    // Anyone can burn their NFT if they have sufficient balance
    function burn(uint _id, uint _amount) external {
        require(balanceOf(msg.sender, _id) >= _amount);
        _burn(msg.sender, _id, _amount);
    }

    function updateName(string calldata _name) public onlyOwner {
        name = _name;
        emit UpdateName(name);
    }

    function ignore(bool _ignore) external onlyOwner {
        emit Ignore(_ignore);
    }

    /**
    * Override isApprovedForAll to whitelist the mastercontract to reward players
    */
    function isApprovedForAll(address _owner, address _operator) public view override returns (bool isOperator) {
        if (_operator == mastercontract) {
        return true;
        }

        return ERC1155.isApprovedForAll(_owner, _operator);
    }

    function withdraw(address payable _to) external { //incase someone want to donate to me? who knows. haha
        require(_to == owner());
        (bool sent,) = _to.call{value: address(this).balance}("");
        require(sent);
    }

    //_balances






}



