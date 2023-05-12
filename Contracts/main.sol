// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.7.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.7.0/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.7.0/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@4.7.0/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts@4.7.0/access/Ownable.sol";
import "./myPet.sol";
import "./core.sol";

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

    uint16 private constant MAX_MINTABLE = 9999;
    uint16 private constant MAX_PER_ATTEMPT = 5;
    uint16 private constant MINTPRICE = 0;
    
    uint16 private constant BATTLESTAMINA = 2 minutes;
    
    uint256 private tokenIdTracker;

    A.myPets[MAX_MINTABLE] public myPet;

    event Result(uint256 indexed id, bool won, uint256 hash, A.myPets selfOrBefore, A.myPets opponOrAfter, uint64 damage, uint bit);
    event StatChangedResult(A.myPets AfterMon);

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }
    //--------------------------------- MINTING FUNCTIONS ------------------------------------
    /**
    * @dev Mints a new myPet to the specified address.
    *
    * @param _to The address to mint the myPet to.
    */
    function _mint(address _to) private {
        // Get the next available token ID.
        uint id = tokenIdTracker;
        tokenIdTracker++;

        // Generate a random number for the myPet's attributes.
        uint _rand = uint(keccak256(abi.encodePacked(msg.sender, block.gaslimit, block.timestamp)));

        // Mint the myPet.
        myPet[id] = core.mintEgg(_rand << ((tokenIdTracker % 50) * 3)); //<<((tokenIdTracker%100)*3)
        myPet[id].attribute.id = uint16(id);
        _safeMint(_to, id);

        // Emit a StatChangedResult event.
        emit StatChangedResult(myPet[id]);
    }

    /**
    * @dev Mints multiple myPets to the specified address.
    *
    * @param _to The address to mint the myPets to.
    * @param _count The number of myPets to mint.
    */
    function mint(address _to, uint256 _count) public payable {
    // Check that the total number of myPets to mint does not exceed the maximum.
        require((tokenIdTracker + _count <= MAX_MINTABLE) && //error.exceed total MAX mintable
                (_count <= MAX_PER_ATTEMPT) && //error.exceed multi-mint max limit
                (msg.value >= _count * MINTPRICE)); //error.less than needed total mint cost

        // Mint the myPets.
        for (uint256 i = 0; i < _count; i++) {
            _mint(_to);
        }
    }

    //----------------------- Raise Functions ---------------------------------------
    function HatchEgg(uint _id) public { //owner,trainer check in function
        uint rand = uint(keccak256(abi.encodePacked(msg.sender, block.gaslimit, block.timestamp)));
        myPet[_id] = core.HatchEgg(myPet[_id], ownerOf(_id));
    }
    function feedsmyPet(uint _id, uint8 _foodtype) public payable { //owner,trainer check in function
        uint rand = uint(keccak256(abi.encodePacked(msg.sender, block.gaslimit, block.timestamp)));
        myPet[_id] = core.FeedmyPet(rand, myPet[_id], _foodtype,ownerOf(_id)); //requirement check on lib
        emit StatChangedResult(myPet[_id]);
    }
    function trainsmyPet(uint _id, uint8 _trainingtype) public { //owner,trainer check in function
        uint rand = uint(keccak256(abi.encodePacked(msg.sender, block.gaslimit, block.timestamp)));
        myPet[_id] = core.trainmyPet(rand, myPet[_id], _trainingtype,ownerOf(_id)); //requirement check on lib
        emit StatChangedResult(myPet[_id]);
    }
    function BattlemyPet(uint _id, uint8 _rank) public {
        //_rank 0 to 255 based on difficulty
        //mysterious forest has 15 level. 
        uint64 _timenow = uint64(block.timestamp);
        require(msg.sender == ownerOf(_id)  &&
                _timenow - myPet[_id].time.stamina >= BATTLESTAMINA && 
                myPet[_id].status == 0 &&
                myPet[_id].time.deadtime > _timenow && myPet[_id].time.endurance > _timenow ); //Alive
        bool Mon1Win;
        uint BattleRhythm;
        uint8 bit; // how many bit has been filled for Rythm
        uint64 damage; //dealt total damage to Mon2
        uint rand = uint(keccak256(abi.encodePacked(msg.sender, block.gaslimit, block.timestamp)));
        uint16 Startcount;
        uint16 Endcount;
        A.myPets memory BattlingmyPet;
        if (rand%3 == 0) {
            //rand go increment
            Startcount = uint16(rand%tokenIdTracker);
            if (myPet.length - Startcount > 1000) {
                Endcount = Startcount+1000; //cap at max 1000 loop
            } else {Endcount = uint16(tokenIdTracker);}
            for(uint16 i=Startcount; i<Endcount; i++){
                if (myPet[i].attribute.stage == _rank+1 && i != _id ) { //right rank and not self
                    BattlingmyPet = myPet[i];
                    Mon1Win = true; //tag along Mon1Win bool to reduce stack //skip generating AI
                    break;
                }
            }
        } else if (rand%3 ==1)
        {
            //rand go decrement
            Startcount = uint16(rand%tokenIdTracker);
            if (Startcount > 1000) {
                Endcount = Startcount - 1000; //cap at max 1000 loop
            } else {Endcount = 0;}
            for(uint16 i=Startcount; i> Endcount; i--){
                if (myPet[i].attribute.stage == _rank+1 && i != _id ) {//right rank and not self
                    BattlingmyPet = myPet[i];
                    Mon1Win = true; //tag along Mon1Win bool to reduce stack //skip generating AI
                    break;
                }
            }
        }
        if (Mon1Win == false) { //tag along with Mon1Win to reduce stack
            BattlingmyPet = core.battlingmyPet(_rank,rand);
        }
        (Mon1Win,BattleRhythm, bit, damage) = core.battlemyPet(rand, myPet[_id], BattlingmyPet);
        myPet[_id] = core.battlewinlosereward(myPet[_id], Mon1Win, _rank, rand); //exp stars gain   
        myPet[_id].time.stamina += BATTLESTAMINA; // take up stamina
        emit Result(_id, Mon1Win, BattleRhythm, myPet[_id], BattlingmyPet,damage, bit); //done battle
        
    }
    function BattleSimulationR(A.myPets memory Mon1, A.myPets memory Mon2) public view //anyone can call -- for external contract
    returns (bool Mon1Win, uint256 BattleRhythm, uint64 damage, uint8 bit ) {//for collaboration with other contract
        uint rand = uint(keccak256(abi.encodePacked(msg.sender, block.gaslimit, block.timestamp)));
        (Mon1Win,BattleRhythm,bit,damage) = core.battlemyPet(rand, Mon1, Mon2);
    }
    
    


    //----------------------- Supporting Functions ---------------------------------------
}
