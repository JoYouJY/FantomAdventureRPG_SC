// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.7.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.7.0/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.7.0/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@4.7.0/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts@4.7.0/access/Ownable.sol";
import "./myPet.sol";

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



contract Main is ERC721Enumerable, ERC721Burnable, Ownable {
    constructor() ERC721("FantomAdventureRPG", "FARPG") {}

   //----------------------- Overribes Functions ---------------------------------------
    /**
    * @dev Overrides the _beforeTokenTransfer function from ERC721 and ERC721Enumerable.
    * @param from - The address from which the token will be transferred.
    * @param to - The address to which the token will be transferred.
    * @param tokenId - The ID of the token to be transferred.
    */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) 
        internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
    * @dev Checks if the contract implements the ERC2981 interface and returns true if it does.
    * @param interfaceId - The interface ID to check for support.
    * @return A boolean indicating whether the contract supports the ERC2981 interface or not.
    */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) 
        returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }
    //----------------------------------------------------------------------------

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    
}
