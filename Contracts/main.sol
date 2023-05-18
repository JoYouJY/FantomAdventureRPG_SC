// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.7.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.7.0/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.7.0/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@4.7.0/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts@4.7.0/access/Ownable.sol";
import "./myPet.sol";
import "./core.sol";
import "./Metadata.sol";
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
    constructor() ERC721("FantomAdventureRPG", "FARPG") {
        setImageURL("https://drive.google.com/file/d/");
    }
    
    

    

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

    uint16 private constant MAX_MINTABLE = 9999;
    uint16 private constant MAX_PER_ATTEMPT = 5;
    uint16 private constant MINTPRICE = 0;
    
    uint16 private constant BATTLESTAMINA = 2 minutes;
    
    uint256 private tokenIdTracker;

    string public baseTokenURI; //in case metadata server/IPFS dead before FTM
    string public imageURL; //in case image server/IPFS dead before FTM
    string public imageExtension;
    string[64] public imageUniquecode = [
        "11dlCP_b6BmnOwo0Ko5OwJdCgmZ00CBRf",
        "",
        "190tUBlUVVOtlj1Pj-P4Qxb4qr-1yEdyB",
        "1IVwNsIFo-4rNFc574zwNgnLIlDZMg-bU",
        "",
        "1JIfap3fPiqoymfn48iCgDXP7xtlQsmjx",
        "",
        "1Q1R4Aaf7W9E74W5lSGlWK_td-U4320Qz",
        "1Vp2i8ZZX0aLKFf29K8BOdtHqqs_Qttj3",
        "",
        "1XFzNfzul7c6LeN2hHaoJm-ic7vlrfP-h",
        "",
        "",
        "",
        "",
        "",
        "1YqVBG6k5SyJMTSam8twacZr-s_msq-0a",
        "1kcFeMIwAlM8mHcKtTlmkguoKDMIqwKpY",
        "",
        "",
        "",
        "",
        "",
        "1lk0d8iUSusVLgaEvAlEDT995TeFYhFga",
        "",
        "",
        "",
        "",
        "",
        "",
        "1nXHzzL--4of15c8ZN9kyGjQVHuuQxEPF",
        "",
        "",
        "",
        "",
        "",
        "",
        "1o5Ql-E72QWO4tATeGWdUK7-MtKJ2q1NN",
        "",
        "",
        "",
        "",
        "",
        "",
        "1oWdGqZKnmPsOJlvr8VgfwUH1CZzebnoX",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "1wGkT9P3Ckxs4ajihD4aXBxHLP1w20dX4",
        "",
        "",
        "1z1hoqk_9L4jQ1uLNB9UGV2aW4kfhOB8m",
        "",
        "",
        "",
        "",
        "",
        ""
    ];
    //TowerLevel 0 is havent start. 1 to 20 is level one.
    // 21 to 40 is level two, and so on. to 181 to 200 for level 10. 
    mapping (address => uint8) public TowerLevel; 
    A.Pets[MAX_MINTABLE] public Pet;

    event Result(uint256 indexed id, bool won, uint256 hash, A.Pets selfOrBefore, A.Pets opponOrAfter, uint64 damage, uint bit);
    event StatChangedResult(A.Pets AfterMon);

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }
    //--------------------------------- MINTING FUNCTIONS ------------------------------------
    /**
    * @dev Mints a new Pet to the specified address.
    *
    * @param _to The address to mint the Pet to.
    */
    function _mint(address _to) private {
        // Get the next available token ID.
        uint id = tokenIdTracker;
        tokenIdTracker++;

        // Generate a random number for the Pet's attributes.
        uint _rand = uint(keccak256(abi.encodePacked(msg.sender, block.timestamp,block.coinbase)));

        // Mint the Pet.
        Pet[id] = core.mintEgg(_rand << ((tokenIdTracker % 50) * 3)); //<<((tokenIdTracker%100)*3)
        Pet[id].attribute.id = uint16(id);
        _safeMint(_to, id);

        // Emit a StatChangedResult event.
        emit StatChangedResult(Pet[id]);
    }

    /**
    * @dev Mints multiple Pets to the specified address.
    *
    * @param _to The address to mint the Pets to.
    * @param _count The number of Pets to mint.
    */
    function mint(address _to, uint256 _count) public payable {
    // Check that the total number of Pets to mint does not exceed the maximum.
        require(balanceOf(_to) <= 20, "MAXIMUM MINT 20 EGGS PER ADDRESS FOR NOW");
        require((tokenIdTracker + _count <= MAX_MINTABLE) && //error.exceed total MAX mintable
                (_count <= MAX_PER_ATTEMPT) && //error.exceed multi-mint max limit
                (msg.value >= _count * MINTPRICE)); //error.less than needed total mint cost

        // Mint the Pets.
        for (uint256 i = 0; i < _count; i++) {
            _mint(_to);
        }
    }

    //----------------------- Raise Functions ---------------------------------------
    function HatchEgg(uint _id) public { //owner,trainer check in function
        Pet[_id] = core.HatchEgg(Pet[_id], ownerOf(_id));
    }
    function feedsPet(uint _id, uint8 _foodtype) public payable { //owner,trainer check in function
        Pet[_id] = core.FeedPet(Pet[_id], _foodtype,ownerOf(_id)); //requirement check on lib
        emit StatChangedResult(Pet[_id]);
    }
    function trainsPet(uint _id, uint8 _trainingtype) public { //owner,trainer check in function
        Pet[_id] = core.trainPet(Pet[_id], _trainingtype,ownerOf(_id)); //requirement check on lib
        emit StatChangedResult(Pet[_id]);
    }

    function BattlePet(uint _id, uint8 _rank) public {
        //_rank 0~3 is AI based on self CP. 
        //_rank 4 = mysterious tower has 10 level.
        uint64 _timenow = uint64(block.timestamp);
        require(msg.sender == ownerOf(_id)  &&
                _timenow - Pet[_id].time.stamina >= BATTLESTAMINA && 
                Pet[_id].time.deadtime > _timenow && Pet[_id].time.endurance > _timenow ); //Alive
        bool Mon1Win;
        uint BattleRhythm;
        uint8 bit; // how many bit has been filled for Rythm
        uint64 damage; //dealt total damage to Mon2
        uint rand = uint(keccak256(abi.encodePacked(msg.sender, block.timestamp)));
        A.Pets memory BattlingPet;
        if (_rank <= 3) { //tag along with Mon1Win to reduce stack
            BattlingPet = core.battlingPet(_rank,rand);
        } else {
            BattlingPet = core.TowerPet(TowerLevel[msg.sender]);
        }
        (Mon1Win,BattleRhythm, bit, damage) = core.battlePet(rand, Pet[_id], BattlingPet);

        if (Mon1Win == false) { //tag along with Mon1Win to reduce stack
            BattlingPet = core.battlingPet(_rank,rand);
        }
        (Mon1Win,BattleRhythm, bit, damage) = core.battlePet(rand, Pet[_id], BattlingPet);
        Pet[_id] = core.battlewinlosereward(Pet[_id], Mon1Win, _rank); //exp stars gain   
        Pet[_id].time.stamina += BATTLESTAMINA; // take up stamina
        emit Result(_id, Mon1Win, BattleRhythm, Pet[_id], BattlingPet,damage, bit); //done battle
        
    }
  
    //----------------------- Owner function ---------------------------------
    function withdraw(address payable _to) external { //incase someone want to donate to me? who knows. haha
        require(_to == owner());
        (bool sent,) = _to.call{value: address(this).balance}("");
        require(sent);
    }
    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI; //IPFS/server is less realiable than FTM IMO. The states are safe in FTM. Only URI link is upgradable.
        //URI is just for marketplace to display.
    }
    function setImageURL(string memory URL) public onlyOwner {
        imageURL = URL;//IPFS/server is less realiable, Only URI link is upgradable.
        //URI is just for marketplace to display.
    }
    function setImageExtension(string memory ext) public onlyOwner {
        imageExtension = ext; //IPFS/server is less realiable, Only URI link is upgradable.
        //URI is just for marketplace to display.
    }
    function setImageUniqueCode(string memory uniquecode, uint index) public onlyOwner {
        imageUniquecode[index] = uniquecode; //IPFS/server is less realiable, Only URI link is upgradable.
        //URI is just for marketplace to display.
    }
    
    //----------------------- Free read Functions ---------------------------------------
    function royaltyInfo(uint, uint _salePrice) external view returns (address, uint) {
        uint royalty = 500;
        address receiver = owner();
        return (receiver, (_salePrice * royalty) / 10000);
    }
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }
    function _imageURI() internal view returns (string memory) {
        return imageURL;
    }
    function viewNFT(uint256 _tokenId) external view returns (A.Pets memory) {
        return Pet[_tokenId];
    }
    function getPetsByOwner(address _owner) public view returns(uint[] memory) {
        uint[] memory result = new uint[](balanceOf(_owner));
        uint counter = 0;
        for (uint i = 0; i < tokenIdTracker; i++) {
            if (ownerOf(i) == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
    function getPetsByOwnerByBatch (address _owner) external view returns(A.Pets[] memory) {
        uint[] memory ids = getPetsByOwner(_owner);
        A.Pets[] memory PetsInfo = new A.Pets[](balanceOf(_owner));
        for (uint i = 0; i < balanceOf(_owner); i++) {
            PetsInfo[i] = Pet[ids[i]];
        }
        return PetsInfo;
    }
    
    function tokenURI(uint256 tokenId) public view override virtual returns (string memory) {
        _requireMinted(tokenId);
        //E.toString(tokenId)
        return Meta.buildURIbased64(Pet[tokenId],imageURL, imageUniquecode[tokenId],uint64(block.timestamp));
    } //I wish Marketplaces able to comply to this...

//--------------------------------------
//ONLY FOR TESTING
    function cheatSTATS(uint _id) public {
        Pet[_id].time.stamina = Pet[_id].time.stamina - 25 hours;
        Pet[_id].time.deadtime = Pet[_id].time.deadtime + 24 hours;
        Pet[_id].time.evolutiontime = uint64(block.timestamp);
        Pet[_id].power.hitpoints = 550000;
        Pet[_id].power.strength = 550;
        Pet[_id].power.agility = 550;
        Pet[_id].power.intellegence = 550;
    }
    function cheatKILL(uint _id) public {
        Pet[_id].time.deadtime = Pet[_id].time.deadtime - 200 hours;
    }
    function cheatGOHUNGRY(uint _id) public {
  //      Pet[_id].time.endurance = uint64(block.timestamp) +  1 hours; 
    } 
    function cheatRevive(uint _id) public {
        Pet[_id].time.deadtime = Pet[_id].time.deadtime + 48 hours;
    }



}
