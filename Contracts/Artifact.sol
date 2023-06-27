//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./base64.sol";
import "./AMetadata.sol";
import "./myArtifact.sol";
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
    bool public confirmed = false;
    bool public stopgen = false;
    string public constant baseUri = "ipfs://";
    string public imageExtension = ".png";
    string public imageURL = "https://ipfs.io/ipfs/QmY2LxnJbFe2e3BeHfsziNxsnube1oGNQaFLPfJnqeqUYh/";
    bool public _namebyID = true; //indicate where it needs to have ID 123 on name
  
    
    function setImageURL(string memory URL) public onlyOwner {
        imageURL = URL;//IPFS/server is less realiable, Only URI link is upgradable.
        //URI is just for marketplace to display.
    }
    function setExtension(string memory exe) public onlyOwner {
        imageExtension = exe;//IPFS/server is less realiable, Only URI link is upgradable.
        //URI is just for marketplace to display.
    }
    mapping (address => uint8[3]) public PlayerEquiped;
    mapping (address => uint[2]) public PlayerLatestAcquiredID_AMOUNT;


    uint public royalty = 750; // base 10000, 750 royalty means 7.5%
    address public royaltyRecipient;

    event MaxMintsReached();
    event UpdateName(string name);
    event Ignore(bool ignore);

    uint public tokenIds = 31;
    using Strings for uint256;

    // Master contract, that can reward players from this reward.
    address public masterContract;
    // The fee for minting
    uint public MINTFEE = 0;

    uint8[] COMMONTREASURE = [1,2,3,4,5,11,12,13,14,15,21,22,23,24,25];
    uint8[] RARETREASURE = [6,7,8,16,17,18,26,27,28];
    uint8[] MYSTICTREASURE = [9,10,19,20,29,30];

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


    function setRoyaltyRecipient(address _royaltyRecipient) external onlyOwner {
        require(_royaltyRecipient != address(0), "royalty cannot be sent to zero address");
        royaltyRecipient = _royaltyRecipient;
    }

    // Maximum number of individual nft tokenIds that can be created
    uint128 public maxMints = 9999;
    uint16[31] public IDMinted; 
    mapping(uint256 => string) internal tokenURIs;

    function mint(
        uint _amount, //want to fix an amount, gold?100m artifact?10k
        address _to,
        uint _id
    ) internal {
        require(msg.sender == masterContract && _id <31, "No Right");
        _mint(_to, _id, _amount, ""); //give ownership to ID
        IDMinted[_id] = IDMinted[_id] + uint16(_amount);
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
    //equip based on slot, have to match, or equip gold/default, which has no effect anyway.
    //slot 0 from metastat means gold. But SLOT1 has to match with SLOT1 or 0 (gold, no effect)
    function equipArtifacts(uint8[3] memory _artifactsID) public {
        require(_artifactsID.length == 3);
        
        uint8 R1 = AMeta.getSlotbyID(_artifactsID[0]);
        uint8 R2 = AMeta.getSlotbyID(_artifactsID[1]);
        uint8 R3 = AMeta.getSlotbyID(_artifactsID[2]);
        
        require(R1 == 1 || R1 == 0);  //right artifact must be in right slot. for R = 0, means its gold, so no effect/default
        require(R2 == 2 || R2 == 0);
        require(R3 == 3 || R3 == 0);
        
        PlayerEquiped[msg.sender] = _artifactsID;
    }

    function getEquipedArtifactsEffects(address _player) public view returns (uint32[4] memory ABCD) {
        uint8[3] memory artifacts = PlayerEquiped[_player];
        uint8[3] memory multiplier;
        
        for (uint8 i = 0; i < 3; i++) {
            if (balanceOf(_player, artifacts[i]) >= 256) {
                multiplier[i] = 9;
            } else if (balanceOf(_player, artifacts[i]) >= 128) {
                multiplier[i] = 8;
            } else if (balanceOf(_player, artifacts[i]) >= 64) {
                multiplier[i] = 7;
            } else if (balanceOf(_player, artifacts[i]) >= 32) {
                multiplier[i] = 6;
            } else if (balanceOf(_player, artifacts[i]) >= 16) {
                multiplier[i] = 5;
            } else if (balanceOf(_player, artifacts[i]) >= 8) {
                multiplier[i] = 4;
            } else if (balanceOf(_player, artifacts[i]) >= 4) {
                multiplier[i] = 3;
            } else if (balanceOf(_player, artifacts[i]) >= 2) {
                multiplier[i] = 2;
            } else if (balanceOf(_player, artifacts[i]) >= 1) {
                multiplier[i] = 1;
            }
            ABCD = AMeta._getEquipedArtifactsEffects(artifacts,multiplier);
        }
    }
    //-------------
//
    function rewardSystem (uint8[4] calldata _chances , address _winner , uint _rand) public { //0=gold, 1=common, 2=rare, 3=mystic
        require(msg.sender == masterContract);
        uint _total = _chances[0] + _chances[1] + _chances[2] + _chances[3] ;
        uint _hit = _rand % _total; //this will get _total -1 as maximum number
        uint _rollID;
        uint _amount =1;
        if (_hit < _chances[0]) {
            // Give gold reward
            mint(_amount,_winner,0); //amount, to , id
        } else if (_hit < (_chances[0] + _chances[1])) {
            // Give common reward
            _rollID = COMMONTREASURE[((_rand>>5)+_rand) % COMMONTREASURE.length];// give common
            if (IDMinted[_rollID] < maxMints) {
                mint(_amount,_winner,_rollID); //amount, to , id // reward  common
            } else {
                _amount = 2;
                mint(_amount,_winner,0); //amount, to , id// give gold instead
            }
        } else if (_hit < (_chances[0] + _chances[1] + _chances[2])) {
            // Give rare reward
            _rollID = RARETREASURE[((_rand>>5)+_rand) % RARETREASURE.length];// give rare
            if (IDMinted[_rollID] < maxMints) {
                mint(_amount,_winner,_rollID); // reward  rare
            } else {
                _amount = 3;
                mint(_amount,_winner,0); //amount, to , id// give gold instead
            }
        } else {
            // Give mystic reward
            _rollID = MYSTICTREASURE[((_rand>>5)+_rand) % MYSTICTREASURE.length];// give mystic
            if (IDMinted[_rollID] < maxMints) {
                mint(_amount,_winner,_rollID);// reward  mystic
            } else {
                _amount = 4;
                mint(_amount,_winner,0); //amount, to , id// give gold instead
            }
        }
        PlayerLatestAcquiredID_AMOUNT[_winner] = [_rollID,_amount];
    }


    //--------------
    function withdraw(address payable _to) external { //incase someone want to donate to me? who knows. haha
        require(_to == owner());
        (bool sent,) = _to.call{value: address(this).balance}("");
        require(sent);
    }

    //----------read only -------------
    function viewArEf(uint8 _tokenId) external pure returns (Ar.ArtifactsEffects memory) {
        return AMeta.getAEbyID(_tokenId);
    }
    function viewArMe(uint8 _tokenId) external pure returns (Ar.ArtifactsMetadata memory) {
        return AMeta.getAMbyID(_tokenId);
    }
    
    function getArtifactsByOwner(address _owner) public view returns(uint[] memory) {
        uint[] memory ownedBalance = new uint[](31); //id's balance in order
        for (uint i = 0; i < 31; i++) {
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
    function getAllArtifactsEffects(uint8 _start, uint8 _stop) public pure returns(Ar.ArtifactsEffects[] memory) {
        uint _totalcount;
        if (_stop-_start+1 < 31) {
            _totalcount = _stop-_start+1;
        } else {
            _totalcount = 31;
        }
        Ar.ArtifactsEffects[] memory allArEf = new Ar.ArtifactsEffects[](_totalcount); //id's balance in order
        for (uint8 i = _start; i < _start+_totalcount; i++) {
            allArEf[i] = AMeta.getAEbyID(i);
        }
        return allArEf;
    }
    function getAllArtifactsMetadata(uint8 _start, uint8 _stop) public pure returns(Ar.ArtifactsMetadata[] memory) {
        uint _totalcount;
        if (_stop-_start+1 < 31) {
            _totalcount = _stop-_start+1;
        } else {
            _totalcount = 31;
        }
        Ar.ArtifactsMetadata[] memory allArMe = new Ar.ArtifactsMetadata[](_totalcount); //id's balance in order
        for (uint8 i = _start; i < _start+_totalcount; i++) {
            allArMe[i] = AMeta.getAMbyID(i);
        }
        return allArMe;
    }
    //for appearance
    function getEquipedBalance(address _owner)public view returns (uint8[3] memory EqID,uint[3] memory EqBalance) {
        EqID = PlayerEquiped[_owner];
        EqBalance[0] = balanceOf(_owner, EqID[0]);
        EqBalance[1] = balanceOf(_owner, EqID[1]);
        EqBalance[2] = balanceOf(_owner, EqID[2]);

    }


    function uri(uint _tokenId) public view virtual override returns (string memory metadata) {
         uint8 tokenID = uint8(_tokenId);
         Ar.ArtifactsEffects memory ArEf = AMeta.getAEbyID(tokenID);
         Ar.ArtifactsMetadata memory ArMe = AMeta.getAMbyID(tokenID);

        string memory _name = ArMe.name;
        string memory _imagelinkfull = string(abi.encodePacked(imageURL,_toString(tokenID), imageExtension));
        string memory _description = ArMe.description;
        
         metadata = string(abi.encodePacked("data:application/json;base64,",
            Base64.encode(
                bytes(
                    abi.encodePacked(
                        "{\"name\": \"#",_toString(tokenID)," ",_name,
                        "\",\"description\": \"",_description,
                        "\",\"image\": \"",
                        _imagelinkfull,
                        _getAttribute1(ArMe,ArEf),
                         _getAttribute2(ArEf)    
                    )
                )
            )
        ));
       
    }
    function _getAttribute1(Ar.ArtifactsMetadata memory AM, Ar.ArtifactsEffects memory AE) private pure returns (string memory attribute){
        
        string memory _slot;
        string memory _rarity;
       
        if (AM.slot == 0) {_slot = "Gold"; }
        else if (AM.slot == 1) {_slot = "Head"; }
        else if (AM.slot == 2) {_slot = "Outfit"; }
        else if (AM.slot == 3) {_slot = "Orb"; }
            else {_slot = "Unknown"; }
        if (AE.R == 0) {_rarity = "Gold"; }
        else if (AE.R == 1) {_rarity = "Common"; }
        else if (AE.R == 2) {_rarity = "Rare"; }
        else if (AE.R == 3) {_rarity = "Mystic"; }
            else {_rarity = "Unknown"; }
        
        attribute = string(abi.encodePacked(
            "\",   \"attributes\": [{\"trait_type\": \"'Slot\",\"value\": \"",bytes(_slot),
             "\"}, {\"trait_type\": \"'Rarity\",\"value\": \"",bytes(_rarity)   
        ));
    }
    function _getAttribute2(Ar.ArtifactsEffects memory AE) private pure returns (string memory attribute){      
        attribute = string(abi.encodePacked(                 
            "\"}, {\"trait_type\": \"::HP\",\"value\": \"",_toString(AE.A),
            "\"}, {\"trait_type\": \"::STR\",\"value\": \"",_toString(AE.B),
            "\"}, {\"trait_type\": \":AGI\",\"value\": \"",_toString(AE.C),
            "\"}, {\"trait_type\": \":INT\",\"value\": \"",_toString(AE.D),
            "\"}]}" 
        ));
    }
    
    function _toString(uint _i) private pure returns (bytes memory convString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return bstr;
    }
    //------------Hackathon Generation -------------
    //Will renowed when submitting to Open Marketplace for fairness
    function cheatArtifact(address _player, uint _id, uint _amount) public {
         if (stopgen == false) {
            mint(_amount,_player,_id); 
         }
    }
    function cheatAllArtifact(address _player, uint _amount) public {
         if (stopgen == false) {
            for (uint i = 0; i < 31; i++) {
                mint(_amount,_player,i); 
            }
         }
    }
    function renowGenArtifactforHackathon() public {
         stopgen = true;
    }
 
}



