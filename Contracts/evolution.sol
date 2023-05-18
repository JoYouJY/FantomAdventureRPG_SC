// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./myPet.sol";
library EVO {
    //---------CONSTANT -----------------------------
    uint64 private constant lifeGainRookie = 365 days; 
    uint64 private constant lifeGainMature = 365 days; 
    uint64 private constant lifeGainPerfect = 365 days; 
    //evolution requirement from
    uint64 private constant RookietoMatureTime = 10 seconds; 
    uint64 private constant MaturetoPerfectTime = 10 seconds; 
    uint64 private constant PerfecttoUnknownTime = 365 days; 
    //--------------- private functions----------------

    function _RandNumb(uint _rand, uint32 _maxRand, uint32 _offset) private pure returns (uint32) {
        return uint32(_rand % (_maxRand-_offset) + _offset);
    }
    
    //--------------MATHS----------------- SATURATED--------
    function sqrt32b(uint32 y) private pure returns (uint32 z) {
        if (y > 3) {
            z = y;
            uint32 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
    function sub64b(uint64 a, uint64 b) private pure returns (uint64) {
    uint64 c;
        if (b <= a){
        c = a - b;
        } else {
        c = 0;
        }
        return c;
    }

    function add64b(uint64 a, uint64 b) private pure returns (uint64) {
        uint64 c; 
        unchecked {c= a + b;}
        if (c < a){
        c = 18446744073709551615;
        }
        return c;
    }
    function sub32b(uint32 a, uint32 b) private pure returns (uint32) {
    uint32 c;
        if (b <= a){
        c = a - b;
        } else {
        c = 0;
        }
        return c;
    }

    function add32b(uint32 a, uint32 b) private pure returns (uint32) {
        uint32 c; 
        unchecked {c= a + b;}
        if (c < a){
        c = 4294967295;
        }
        return c;
    }
    function sub8b(uint8 a, uint8 b) private pure returns (uint8) {
    uint8 c;
        if (b <= a){
        c = a - b;
        } else {
        c = 0;
        }
        return c;
    }
    function add8b(uint8 a, uint8 b) private pure returns (uint8) {
        uint8 c; 
        unchecked {c= a + b;}
        if (c < a){
        c = 255;
        }
        return c;
    }
    function add9L(uint8 a, uint8 b) private pure returns (uint8) {
        uint8 c; 
        unchecked {c= a + b;}
        if (c < a || c>9){
        c = 9;
        }
        return c;
    }
    function add16B999L(uint16 a, uint16 b) private pure returns (uint16) {
        uint16 c; 
        unchecked {c= a + b;}
        if (c < a || c>999){
        c = 999;
        }
        return c;
    }
    function add32B999999L(uint32 a, uint32 b) private pure returns (uint32) {
        uint32 c; 
        unchecked {c= a + b;}
        if (c < a || c>999999){
        c = 999999;
        }
        return c;
    }
    //-----------------------------------------------------
    function _returnLevel(uint32 _exp) private pure returns (uint32 _level){
        _level= sqrt32b(_exp)/258 + 1; //min level 1 - max level 255
        
    }

    function _getGene(uint256 _gene, uint8 _order) private pure returns (uint8) { 
        //order position count from 1 from LSB
        //e.g. gene 1335745, order 2, returns 4 
        return uint8((_gene/10**(_order-1)) - (_gene / 10**(_order))*10);
    }
    function _setGene(uint256 _gene, uint8 _order, uint8 _setNum) private pure returns (uint256 gene) { 
        //order position count from 1 from LSB
        //e.g. gene 1335745, order 2, setNum 9 returns 1335795
        
        uint x = _gene - (_gene/(10**(_order-1))*(10**(_order-1))); //xxX45
        uint y = (_gene/(10**(_order))*(10**(_order))); //123Xxx
        gene = _setNum*10**(_order-1) + x + y;    
    }

    function _ShinningGive(uint _rand, uint32 _exp) private pure returns (bool){
        if( _RandNumb(_rand,255,0)<= _returnLevel(_exp) ){return true;} else {return false;}
    }
//-------------------------------------------------------------------------------
//-----------EXTERNAL ------------v

    function checkEvolve(A.Pets memory _Pet) external view returns (A.Pets memory){
        uint64 timenow= uint64(block.timestamp);
        //evolved to rookie lvl 14, to mature lvl18, to perfect lvl 20
        uint8 species = _Pet.species;
        if (_Pet.attribute.stage == 1 && (_returnLevel(_Pet.exp) >= 14) && _Pet.time.evolutiontime < timenow) { //youth to rookie and reach level 14
            if        (species == 5){
                (_Pet,) = _EvolveID10RQ(1,_Pet);
  //          } else if (species == 6) {
  //              (_Pet,) = _EvolveID14RQ(1,_Pet);  //Cut feature due to timeline for Hackathon
            } else if (species == 7) {
                (_Pet,) = _EvolveID16RQ(1,_Pet);
            } else if (species == 8) {
                (_Pet,) = _EvolveID17RQ(1,_Pet);
    //        } else if (species == 9) {
    //            (_Pet,) = _EvolveID19RQ(1,_Pet);
            }
            
        } else if (_Pet.attribute.stage == 2 && (_returnLevel(_Pet.exp) >= 18) && _Pet.time.evolutiontime < timenow) { //rookie to mature and reach level 18
            if        (species == 10){ //link to above
                (_Pet,) = _EvolveID23RQ(1,_Pet);
    //        } else if (species == 14) {
    //            (_Pet,) = _EvolveID32RQ(1,_Pet); //Cut feature due to timeline for Hackathon
            } else if (species == 16) {
                (_Pet,) = _EvolveID30RQ(1,_Pet);
            } else if (species == 17) {
                (_Pet,) = _EvolveID37RQ(1,_Pet);
    //        } else if (species == 19) {
    //            (_Pet,) = _EvolveID27RQ(1,_Pet);
            }
            
        } else if (_Pet.attribute.stage == 3 && (_returnLevel(_Pet.exp) >= 20) && _Pet.time.evolutiontime < timenow) { //mature to perfect and reach level 20
            if        (species == 23){ //link to above
                (_Pet,) = _EvolveID44RQ(1,_Pet);
    //        } else if (species == 32) {
    //            (_Pet,) = _EvolveID53RQ(1,_Pet);  //Cut feature due to timeline for Hackathon
            } else if (species == 30) {
                (_Pet,) = _EvolveID57RQ(1,_Pet);
            } else if (species == 37) {
                (_Pet,) = _EvolveID54RQ(1,_Pet);
    //        } else if (species == 27) {
    //            (_Pet,) = _EvolveID49RQ(1,_Pet);
            }
        }
        return _Pet;
    }


    //------------- Evolution Requirement -------------------
    //------ Start from 10, 0 to 9 are basic and fixed via hatchegg function------
//--------------- 10 to 22, 13 Rookies -----------------  20 Mature, 21 Perfect later
//----------------  R O O K I E ----------------------------//
           function _EvolveID10RQ(uint rand, A.Pets memory _Pet) private view //Wiggle
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<1,4,0) < 3 && //60% chance to evolve to this
            _Pet.attribute.weight<1600   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 10; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,25000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,25);
            _Pet.power.agility = add16B999L(_Pet.power.agility,110);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,35);
            _Pet.time.deadtime = add64b(_Pet.time.deadtime,lifeGainRookie);
            _Pet.time.evolutiontime = add64b(uint64(block.timestamp),RookietoMatureTime);
            _Pet.attribute.stage = 2; 
            _Pet.trait[0] = uint8(_RandNumb(rand<<6,31,1));      //evolve gain 1 random trait
            _Pet.skill[0] = _Pet.species;      //evolve gain 1 skill/////////////////////////<----- which is its own ID example 10
        } else { //evolve fail
            MeetRQ = false;
        }
        return (_Pet,MeetRQ);
    }
      
      function _EvolveID16RQ(uint rand, A.Pets memory _Pet) private view //Wingoid
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<13,4,0) < 3 && //60% chance to evolve to this
            _Pet.attribute.weight<2500   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 16; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,30000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,40);
            _Pet.power.agility = add16B999L(_Pet.power.agility,77);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,56);
            _Pet.time.deadtime = add64b(_Pet.time.deadtime,lifeGainRookie);
            _Pet.time.evolutiontime = add64b(uint64(block.timestamp),RookietoMatureTime);
            _Pet.attribute.stage = 2; 
            _Pet.trait[0] = uint8(_RandNumb(rand<<6,31,1));      //evolve gain 1 random trait
            _Pet.skill[0] = _Pet.species;      //evolve gain 1 skill/////////////////////////<----- which is its own ID example 10
        } else { //evolve fail
            MeetRQ = false;
        }
        return (_Pet,MeetRQ);
    }
      function _EvolveID17RQ(uint rand, A.Pets memory _Pet) private view //IO-der
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<15,4,0) < 3 && //60% chance to evolve to this
            _Pet.attribute.discipline>=150   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 17; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,70000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,50);
            _Pet.power.agility = add16B999L(_Pet.power.agility,40);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,50);
            _Pet.time.deadtime = add64b(_Pet.time.deadtime,lifeGainRookie);
            _Pet.time.evolutiontime = add64b(uint64(block.timestamp),RookietoMatureTime);
            _Pet.attribute.stage = 2; 
            _Pet.trait[0] = uint8(_RandNumb(rand<<6,31,1));      //evolve gain 1 random trait
            _Pet.skill[0] = _Pet.species;      //evolve gain 1 skill/////////////////////////<----- which is its own ID example 10
        } else { //evolve fail
            MeetRQ = false;
        }
        return (_Pet,MeetRQ);
    }
      function _EvolveID23RQ(uint rand, A.Pets memory _Pet) private view //Steelhead
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<27,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.agility>=180 &&
            _Pet.attribute.happiness<=100   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 23; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,100000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,80);
            _Pet.power.agility = add16B999L(_Pet.power.agility,120);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,55);
            _Pet.time.deadtime = add64b(_Pet.time.deadtime,lifeGainMature);
            _Pet.time.evolutiontime = add64b(uint64(block.timestamp),MaturetoPerfectTime);
            _Pet.attribute.stage = 3; 
            _Pet.trait[1] = uint8(_RandNumb(rand<<6,31,1));      //evolve gain 1 random trait
            _Pet.skill[1] = _Pet.species;      //evolve gain 1 skill/////////////////////////<----- which is its own ID example 10
        } else { //evolve fail
            MeetRQ = false;
        }
        return (_Pet,MeetRQ);
    }
      function _EvolveID30RQ(uint rand, A.Pets memory _Pet) private view //Birdori
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<41,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.agility>=180 &&
            _Pet.attribute.happiness>120 &&
            _Pet.attribute.weight<7000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 30; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,95000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,110);
            _Pet.power.agility = add16B999L(_Pet.power.agility,120);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,70);
            _Pet.time.deadtime = add64b(_Pet.time.deadtime,lifeGainMature);
            _Pet.time.evolutiontime = add64b(uint64(block.timestamp),MaturetoPerfectTime);
            _Pet.attribute.stage = 3; 
            _Pet.trait[1] = uint8(_RandNumb(rand<<6,31,1));      //evolve gain 1 random trait
            _Pet.skill[1] = _Pet.species;      //evolve gain 1 skill/////////////////////////<----- which is its own ID example 10
        } else { //evolve fail
            MeetRQ = false;
        }
        return (_Pet,MeetRQ);
    }
      function _EvolveID37RQ(uint rand, A.Pets memory _Pet) private view //Ointank
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<55,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>=180000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 37; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,190000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,110);
            _Pet.power.agility = add16B999L(_Pet.power.agility,77);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,44);
            _Pet.time.deadtime = add64b(_Pet.time.deadtime,lifeGainMature);
            _Pet.time.evolutiontime = add64b(uint64(block.timestamp),MaturetoPerfectTime);
            _Pet.attribute.stage = 3; 
            _Pet.trait[1] = uint8(_RandNumb(rand<<6,31,1));      //evolve gain 1 random trait
            _Pet.skill[1] = _Pet.species;      //evolve gain 1 skill/////////////////////////<----- which is its own ID example 10
        } else { //evolve fail
            MeetRQ = false;
        }
        return (_Pet,MeetRQ);
    }
      function _EvolveID44RQ(uint rand, A.Pets memory _Pet) private view //Solanake
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<69,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>300000 &&
            _Pet.power.agility>400 &&
            _Pet.power.intellegence>200 &&
            _Pet.attribute.discipline<50 &&
            _Pet.attribute.weight>60000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 44; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,176000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,198);
            _Pet.power.agility = add16B999L(_Pet.power.agility,220);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,200);
            _Pet.time.deadtime = add64b(_Pet.time.deadtime,lifeGainPerfect);
            _Pet.time.evolutiontime = add64b(uint64(block.timestamp),PerfecttoUnknownTime);
            _Pet.attribute.stage = 4; 
            _Pet.trait[2] = uint8(_RandNumb(rand<<6,31,1));      //evolve gain 1 random trait
            _Pet.skill[2] = _Pet.species;      //evolve gain 1 skill/////////////////////////<----- which is its own ID example 10
        } else { //evolve fail
            MeetRQ = false;
        }
        return (_Pet,MeetRQ);
    }
      function _EvolveID54RQ(uint rand, A.Pets memory _Pet) private view //Mechindragon
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<89,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>500000 &&
            _Pet.power.strength>400 &&
            _returnLevel(_Pet.exp)>40 &&
            _Pet.attribute.weight>140000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 54; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,245000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,209);
            _Pet.power.agility = add16B999L(_Pet.power.agility,178);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,200);
            _Pet.time.deadtime = add64b(_Pet.time.deadtime,lifeGainPerfect);
            _Pet.time.evolutiontime = add64b(uint64(block.timestamp),PerfecttoUnknownTime);
            _Pet.attribute.stage = 4; 
            _Pet.trait[2] = uint8(_RandNumb(rand<<6,31,1));      //evolve gain 1 random trait
            _Pet.skill[2] = _Pet.species;      //evolve gain 1 skill/////////////////////////<----- which is its own ID example 10
        } else { //evolve fail
            MeetRQ = false;
        }
        return (_Pet,MeetRQ);
    }
      function _EvolveID57RQ(uint rand, A.Pets memory _Pet) private view //Feroth
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<95,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>400000 &&
            _Pet.power.strength>300 &&
            _Pet.power.intellegence>350 &&
            _returnLevel(_Pet.exp)>23 &&
            _Pet.attribute.happiness<50   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 57; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,170000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,233);
            _Pet.power.agility = add16B999L(_Pet.power.agility,166);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,233);
            _Pet.time.deadtime = add64b(_Pet.time.deadtime,lifeGainPerfect);
            _Pet.time.evolutiontime = add64b(uint64(block.timestamp),PerfecttoUnknownTime);
            _Pet.attribute.stage = 4; 
            _Pet.trait[2] = uint8(_RandNumb(rand<<6,31,1));      //evolve gain 1 random trait
            _Pet.skill[2] = _Pet.species;      //evolve gain 1 skill/////////////////////////<----- which is its own ID example 10
        } else { //evolve fail
            MeetRQ = false;
        }
        return (_Pet,MeetRQ);
    }
  


}
