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



contract FARPGartifacts is IERC2981, ERC1155 {
    string public name = "FantomAdventureRPG Artifact";
    string public symbol = "aFARPG";

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

    event Initialized(string name);
    event MaxMintsReached();
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event UpdateName(string name);
    event Ignore(bool ignore);

    string public constant baseUri = "ipfs://";
    using Counters for Counters.Counter;
    Counters.Counter public tokenIds;
    using Strings for uint256;

    // Master contract, that can reward players from this reward.
    address internal mastercontract;
    // The fee for minting
    uint public mintFee;
    // The destination adddress
    address public devAddr;
    // The owner of the contract
    address public owner;
    // Maximum number of individual nft tokenIds that can be created
    uint128 public maxMints;
    mapping(uint256 => string) internal tokenURIs;
    

    constructor() ERC1155("") {}

    function uri(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId));

        // If there is no base URI, return the token URI.
        if (bytes(baseUri).length == 0) {
        return tokenURIs[_tokenId];
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(tokenURIs[_tokenId]).length > 0) {
        return string(abi.encodePacked(baseUri, tokenURIs[_tokenId]));
        }

        return super.uri(_tokenId);
    }

    function batchMint(
        address _to,
        uint256[] memory _amounts,
        string[] memory _uris
    ) external payable onlyOwner {
        require(_amounts.length == _uris.length);
        require(msg.value == mintFee * _amounts.length, "Not enough ftm");

        uint[] memory ids = new uint[](_amounts.length);
        for (uint i = 0; i < _amounts.length; ++i) {
        tokenIds.increment();
        uint256 id = tokenIds.current();
        ids[i] = id;
        tokenURIs[id] = _uris[i];
        }

        require(tokenIds.current() <= maxMints);
        if (tokenIds.current() == maxMints) {
        emit MaxMintsReached();
        }

        _mintBatch(_to, ids, _amounts, "");

        // Send FTM fee to fee recipient
        (bool success, ) = devAddr.call{value: msg.value}("");
        require(success, "Transfer failed");
    }

    // The uri must be in the form of ipfs:// where the ipfs:// prefix has been stripped
    function mint(
        address _to,
        uint _amount,
        string memory _uri
    ) external payable onlyOwner {
        require(msg.value == mintFee, "Not enough ftm");

        tokenIds.increment();
        uint256 id = tokenIds.current();
        _mint(_to, id, _amount, "");
        tokenURIs[id] = _uri;

        require(tokenIds.current() <= maxMints);
        if (tokenIds.current() == maxMints) {
        emit MaxMintsReached();
        }

        // Send FTM fee to recipient
        (bool success, ) = devAddr.call{value: msg.value}("");
        require(success, "Transfer failed");
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

    function _exists(uint256 tokenId) private view returns (bool) {
        return bytes(tokenURIs[tokenId]).length != 0;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    *
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    /**
    * @dev Transfers ownership of the contract to a new account (`newOwner`).
    * Can only be called by the current owner.
    */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}



