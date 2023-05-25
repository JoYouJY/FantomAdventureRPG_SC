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
    bool public confirmed = false;
    // A struct to hold the Artifact's effects, keep it simple as it needed by master contract
    struct ArtifactsEffects {
        uint16 id;         // The unique ID of the Pet, used to track the same token
        uint32 A;   // HP +
        uint32 B;  // STR +
        uint32 C;   // AGI +
        uint32 D;   // INT +
        uint8 R; // rarity 0 = gold, 1 = common, 2 = rare, 3 = mystical
        uint8 set; // if there is set artifact, this will indicate whether they are same set for extra effect
    }
    struct ArtifactsMetadata {
        string name;   // The name of the artifact
        string description;   // The unique ID of the Pet, used to track the same token
        string ipfs;   // should be ipfs folder, e.g. SDF4DW12ER123EFASFG234/ , remember the '/' at the end
        uint8 slot; //this artifact is meant to wear for head/body/etc
        uint32 timestamp; //release date/item discovered
    }
    string public constant baseUri = "ipfs://";
    string public imageExtension = ".jpg";
    ArtifactsEffects[MAX_MINTABLE] public ArEf;
    ArtifactsMetadata[MAX_MINTABLE] public ArMe;

    mapping (address => uint[]) public PlayerEquiped;

    uint public royalty; // base 10000, 750 royalty means 7.5%
    address public royaltyRecipient;

    event MaxMintsReached();
    event UpdateName(string name);
    event Ignore(bool ignore);

    using Counters for Counters.Counter;
    Counters.Counter public tokenIds;
    using Strings for uint256;

    // Master contract, that can reward players from this reward.
    address public masterContract;
    // The fee for minting
    uint public MINTFEE = 0;

    function setMasterContract (address _master) public onlyOwner {
        if (confirmed == false) {
            masterContract = _master;
        }
    }
    function confirmMasterContract () public onlyOwner {
        confirmed = true;
    }


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

   
    
    
    // Maximum number of individual nft tokenIds that can be created
    uint128 public maxMints = 9000;
    mapping(uint256 => string) internal tokenURIs;
    

    

    function uri(uint256 _tokenId) public view virtual override returns (string memory) {

        // If there is no base URI, return the token URI.
        if (bytes(baseUri).length == 0) {
        return tokenURIs[_tokenId];
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
 /*       if (bytes(tokenURIs[_tokenId]).length > 0) {
        return string(abi.encodePacked(baseUri, _tokenId, imageExtension));
        } */
        return string(abi.encodePacked(baseUri,ArMe[_tokenId].ipfs, imageExtension));
  //      return super.uri(_tokenId);
    }

    function batchMint(
        uint256[] memory _amounts,
        ArtifactsEffects[] memory _effects,
        ArtifactsMetadata[] memory _metadata
    ) external payable onlyOwner {
        require((_amounts.length == _effects.length) && _amounts.length == _metadata.length); //make sure the array size are matched
        require(msg.value == MINTFEE * _amounts.length, "Not enough ftm");

        uint[] memory ids = new uint[](_amounts.length);
        for (uint i = 0; i < _amounts.length; ++i) {   
            uint256 id = tokenIds.current();
            ids[i] = id;
            ArEf[id] = _effects[id];
            ArEf[id].id = uint16(id);
            ArMe[id] = _metadata[id]; //date of release cannot be editted. that is the uniqueness and value of NFT
            ArMe[id].timestamp = uint32(block.timestamp);
            tokenIds.increment();
        }

        require(tokenIds.current() <= maxMints);
        if (tokenIds.current() == maxMints) {
        emit MaxMintsReached();
        }

        _mintBatch(masterContract, ids, _amounts, "");


    }

    // The uri must be in the form of ipfs:// where the ipfs:// prefix has been stripped
    function mint(
        uint _amount, //want to fix an amount, gold?100m artifact?10k
        ArtifactsEffects memory _effects,
        ArtifactsMetadata memory _metadata
    ) external payable onlyOwner {
        require(msg.value == MINTFEE, "Not enough ftm");
        uint256 id = tokenIds.current();
        _mint(masterContract, id, _amount, ""); //give ownership to ID
        ArEf[id] = _effects;
        ArEf[id].id = uint16(id);
        ArMe[id] = _metadata; //date of release cannot be editted. that is the uniqueness and value of NFT
        ArMe[id].timestamp = uint32(block.timestamp);
        tokenIds.increment();
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
        if (_operator == masterContract) {
        return true;
        }

        return ERC1155.isApprovedForAll(_owner, _operator);
    }


    //-------------------- Action -------------------------

    function equipArtifacts(address _player, uint[] memory _artifacts) public {
        require(_player == msg.sender && _artifacts.length == 3);
    
        uint8 R0 = ArMe[_artifacts[0]].slot;
        uint8 R1 = ArMe[_artifacts[1]].slot;
        uint8 R2 = ArMe[_artifacts[2]].slot;
        
        require(R0 == 1 || R0 == 0);  //right artifact must be in right slot. for R = 0, means its gold, so no effect/default
        require(R1 == 2 || R1 == 0);
        require(R2 == 3 || R2 == 0);
        
        PlayerEquiped[_player] = _artifacts;
    }

    function getEquipedArtifactsEffects(address _player) public view returns (uint32[4] memory ABCD) {
        uint[] memory artifacts = PlayerEquiped[_player];
        uint8 multiplier;
        
        for (uint8 i = 0; i < 3; i++) {
            if (balanceOf(_player, artifacts[i]) >= 256) {
                multiplier = 9;
            } else if (balanceOf(_player, artifacts[i]) >= 128) {
                multiplier = 8;
            } else if (balanceOf(_player, artifacts[i]) >= 64) {
                multiplier = 7;
            } else if (balanceOf(_player, artifacts[i]) >= 32) {
                multiplier = 6;
            } else if (balanceOf(_player, artifacts[i]) >= 16) {
                multiplier = 5;
            } else if (balanceOf(_player, artifacts[i]) >= 8) {
                multiplier = 4;
            } else if (balanceOf(_player, artifacts[i]) >= 4) {
                multiplier = 3;
            } else if (balanceOf(_player, artifacts[i]) >= 2) {
                multiplier = 2;
            } else if (balanceOf(_player, artifacts[i]) >= 1) {
                multiplier = 1;
            }
            if (multiplier > 0) {
                ABCD[0] = ABCD[0] + (ArEf[artifacts[i]].A * multiplier);
                ABCD[1] = ABCD[1] + (ArEf[artifacts[i]].B * multiplier);
                ABCD[2] = ABCD[2] + (ArEf[artifacts[i]].C * multiplier);
                ABCD[3] = ABCD[3] + (ArEf[artifacts[i]].D * multiplier);
            }
        }
    }

    function withdraw(address payable _to) external { //incase someone want to donate to me? who knows. haha
        require(_to == owner());
        (bool sent,) = _to.call{value: address(this).balance}("");
        require(sent);
    }





    //----------read only -------------
    function viewArEf(uint256 _tokenId) external view returns (ArtifactsEffects memory) {
        return ArEf[_tokenId];
    }
    function viewArMe(uint256 _tokenId) external view returns (ArtifactsMetadata memory) {
        return ArMe[_tokenId];
    }
    
    function getArtifactsByOwner(address _owner) public view returns(uint[] memory) {
        uint[] memory ownedBalance = new uint[](tokenIds.current()); //id's balance in order
        for (uint i = 0; i < tokenIds.current(); i++) {
            if (balanceOf(_owner,i) > 0) {
                ownedBalance[i] = balanceOf(_owner,i);
            }
        }
        return ownedBalance;
    }
    function getNumberofUniqueArtifactsof(address _owner) public view returns(uint[] memory) {
        uint[] memory ownedBalance = getArtifactsByOwner(_owner);
        uint counter;
        for (uint i = 0; i < ownedBalance.length; i++) {
            if (ownedBalance[i] > 0) {
                counter++;
            }
        }
        return ownedBalance;
    }
    function getAllArtifactsEffects(uint _start, uint _stop) public view returns(ArtifactsEffects[] memory) {
        uint _totalcount;
        if (_stop-_start+1 < tokenIds.current()) {
            _totalcount = _stop-_start+1;
        } else {
            _totalcount = tokenIds.current();
        }
        ArtifactsEffects[] memory allArEf = new ArtifactsEffects[](_totalcount); //id's balance in order
        for (uint i = _start; i < _start+_totalcount; i++) {
            allArEf[i] = ArEf[i];
        }
        return allArEf;
    }
    function getAllArtifactsMetadata(uint _start, uint _stop) public view returns(ArtifactsMetadata[] memory) {
        uint _totalcount;
        if (_stop-_start+1 < tokenIds.current()) {
            _totalcount = _stop-_start+1;
        } else {
            _totalcount = tokenIds.current();
        }
        ArtifactsMetadata[] memory allArMe = new ArtifactsMetadata[](_totalcount); //id's balance in order
        for (uint i = _start; i < _start+_totalcount; i++) {
            allArMe[i] = ArMe[i];
        }
        return allArMe;
    }





}



