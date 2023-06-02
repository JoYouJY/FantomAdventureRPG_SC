//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./base64.sol";
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
        uint8 slot; //this artifact is meant to wear for head/body/etc
        uint32 timestamp; //release date/item discovered
    }
    string public constant baseUri = "ipfs://";
    string public imageExtension = ".jpg";
    string public imageURL = "https://ipfs.io/ipfs/QmU9ErbrZsECw9JdGpEn4wsVkMeKRrDqhCxYy1A6mzMpAy/";
    bool public _namebyID = true; //indicate where it needs to have ID 123 on name
    ArtifactsEffects[MAX_MINTABLE] public ArEf;
    ArtifactsMetadata[MAX_MINTABLE] public ArMe;
    
    function setImageURL(string memory URL) public onlyOwner {
        imageURL = URL;//IPFS/server is less realiable, Only URI link is upgradable.
        //URI is just for marketplace to display.
    }
    function setExtension(string memory exe) public onlyOwner {
        imageExtension = exe;//IPFS/server is less realiable, Only URI link is upgradable.
        //URI is just for marketplace to display.
    }
    mapping (address => uint[3]) public PlayerEquiped;
    mapping (address => uint[2]) public PlayerLatestAcquiredID_AMOUNT;


    uint public royalty = 750; // base 10000, 750 royalty means 7.5%
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

    uint[] COMMONTREASURE;
    uint[] RARETREASURE;
    uint[] MYSTICTREASURE;

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
    uint128 public maxMints = 9000;
    mapping(uint256 => string) internal tokenURIs;
    
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
            ArEf[id] = _effects[i];
            if (_effects[i].R == 1) {COMMONTREASURE.push(id);}
            else if (_effects[i].R == 2) {RARETREASURE.push(id);}
            else if (_effects[i].R == 3) {MYSTICTREASURE.push(id);}
            ArEf[id].id = uint16(id);
            ArMe[id] = _metadata[i]; //date of release cannot be editted. that is the uniqueness and value of NFT
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
        if (_effects.R == 1) {COMMONTREASURE.push(id);}
        else if (_effects.R == 2) {RARETREASURE.push(id);}
        else if (_effects.R == 3) {MYSTICTREASURE.push(id);}
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
    //equip based on slot, have to match, or equip gold/default, which has no effect anyway.
    //slot 0 from metastat means gold. But SLOT1 has to match with SLOT1 or 0 (gold, no effect)
    function equipArtifacts(address _player, uint[3] memory _artifacts) public {
        require(_player == msg.sender && _artifacts.length == 3);
        
        uint8 R1 = ArMe[_artifacts[0]].slot;
        uint8 R2 = ArMe[_artifacts[1]].slot;
        uint8 R3 = ArMe[_artifacts[2]].slot;
        
        require(R1 == 1 || R1 == 0);  //right artifact must be in right slot. for R = 0, means its gold, so no effect/default
        require(R2 == 2 || R2 == 0);
        require(R3 == 3 || R3 == 0);
        
        PlayerEquiped[_player] = _artifacts;
    }

    function getEquipedArtifactsEffects(address _player) public view returns (uint32[4] memory ABCD) {
        uint[3] memory artifacts = PlayerEquiped[_player];
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
            _safeTransferFrom(masterContract,_winner,0,_amount,""); //from, to, id, amount
        } else if (_hit < (_chances[0] + _chances[1])) {
            // Give common reward
            _rollID = COMMONTREASURE[((_rand>>5)+_rand) % COMMONTREASURE.length];// give common
            if (balanceOf(masterContract,_rollID) >= 1) {
                _safeTransferFrom(masterContract,_winner,_rollID,_amount,""); //from, to, id, amount // Transfer common
            } else {
                _amount = 2;
                _safeTransferFrom(masterContract,_winner,0,_amount,""); //from, to, id, amount// give gold instead
            }
        } else if (_hit < (_chances[0] + _chances[1] + _chances[2])) {
            // Give rare reward
            _rollID = RARETREASURE[((_rand>>5)+_rand) % RARETREASURE.length];// give rare
            if (balanceOf(masterContract,_rollID) >= 1) {
                _safeTransferFrom(masterContract,_winner,_rollID,_amount,""); //from, to, id, amount // Transfer rare
            } else {
                _amount = 3;
                _safeTransferFrom(masterContract,_winner,0,_amount,""); //from, to, id, amount// give gold instead
            }
        } else {
            // Give mystic reward
            _rollID = MYSTICTREASURE[((_rand>>5)+_rand) % MYSTICTREASURE.length];// give mystic
            if (balanceOf(masterContract,_rollID) >= 1) {
                _safeTransferFrom(masterContract,_winner,_rollID,_amount,""); //from, to, id, amount // Transfer mystic
            } else {
                _amount = 4;
                _safeTransferFrom(masterContract,_winner,0,_amount,""); //from, to, id, amount// give gold instead
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
    //for appearance
    function getEquipedBalance(address _owner)public view returns (uint[3] memory EqID,uint[3] memory EqBalance) {
        EqID = PlayerEquiped[_owner];
        EqBalance[0] = balanceOf(_owner, EqID[0]);
        EqBalance[1] = balanceOf(_owner, EqID[1]);
        EqBalance[2] = balanceOf(_owner, EqID[2]);

    }


    function uri(uint256 _tokenId) public view virtual override returns (string memory metadata) {
        string memory _name = ArMe[_tokenId].name;
        string memory _imagelinkfull = string(abi.encodePacked(imageURL,_toString(_tokenId), imageExtension));
        string memory _description = ArMe[_tokenId].description;
        
         metadata = string(abi.encodePacked("data:application/json;base64,",
            Base64.encode(
                bytes(
                    abi.encodePacked(
                        "{\"name\": \"#",_toString(_tokenId)," ",_name,
                        "\",\"description\": \"",_description,
                        "\",\"image\": \"",
                        _imagelinkfull,
                        _getAttribute1(ArMe[_tokenId],ArEf[_tokenId]),
                         _getAttribute2(ArEf[_tokenId])    
                    )
                )
            )
        ));
       
    }
    function _getAttribute1(ArtifactsMetadata memory AM, ArtifactsEffects memory AE) private pure returns (string memory attribute){
        
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
             "\"}, {\"trait_type\": \"'Rarity\",\"value\": \"",bytes(_rarity),   
            "\"}, {\"trait_type\": \"'Edition\",\"value\": \"",bytes(convertToDate(AM.timestamp))     
        ));
    }
    function _getAttribute2(ArtifactsEffects memory AE) private pure returns (string memory attribute){      
        attribute = string(abi.encodePacked(                 
            "\"}, {\"trait_type\": \"::HP\",\"value\": \"",_toString(AE.A),
            "\"}, {\"trait_type\": \"::STR\",\"value\": \"",_toString(AE.B),
            "\"}, {\"trait_type\": \":AGI\",\"value\": \"",_toString(AE.C),
            "\"}, {\"trait_type\": \":INT\",\"value\": \"",_toString(AE.D),
            "\"}]}" 
        ));
    }
    function convertToDate(uint32 timestamp) private pure returns (string memory) {
        uint256 unixTimestamp = timestamp;
        uint256 day = unixTimestamp / 86400; // Number of seconds in a day
        uint256 unixTimestampDays = day * 86400;
        uint256 year;
        uint256 month;
        uint256 dayOfMonth;
        uint256 SECONDS_IN_YEAR = 31536000; // Number of seconds in a year
        for (year = 1970; ; year++) {
            if (unixTimestampDays >= SECONDS_IN_YEAR) {
                if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
                    if (unixTimestampDays < SECONDS_IN_YEAR + 86400) break; // Leap year
                    unixTimestampDays -= SECONDS_IN_YEAR + 86400;
                } else {
                    if (unixTimestampDays < SECONDS_IN_YEAR) break; // Non-leap year
                    unixTimestampDays -= SECONDS_IN_YEAR;
                }
            } else {
                break;
            }
        }
        bool leapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
        uint256[12] memory monthDayCounts;
        monthDayCounts[0] = 31;
        monthDayCounts[1] = leapYear ? 29 : 28;
        monthDayCounts[2] = 31;
        monthDayCounts[3] = 30;
        monthDayCounts[4] = 31;
        monthDayCounts[5] = 30;
        monthDayCounts[6] = 31;
        monthDayCounts[7] = 31;
        monthDayCounts[8] = 30;
        monthDayCounts[9] = 31;
        monthDayCounts[10] = 30;
        monthDayCounts[11] = 31;

        for (month = 1; month <= 12; month++) {
            if (unixTimestampDays < monthDayCounts[month - 1] * 86400) break;
            unixTimestampDays -= monthDayCounts[month - 1] * 86400;
        }

        dayOfMonth = unixTimestampDays / 86400 + 1;

        return string(abi.encodePacked(
            uintToStr(dayOfMonth, 2),
            "/",
            uintToStr(month, 2),
            "/",
            uintToStr(year, 4)
        ));
    }

    function uintToStr(uint256 value, uint256 digits) internal pure returns (string memory) {
        bytes memory buffer = new bytes(digits);
        for (uint256 i = digits; i > 0; i--) {
            buffer[i - 1] = bytes1(uint8(48 + value % 10));
            value /= 10;
        }
        return string(buffer);
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
 
}



