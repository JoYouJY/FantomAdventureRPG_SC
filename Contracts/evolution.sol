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
            } else if (species == 6) {
                (_Pet,) = _EvolveID14RQ(1,_Pet);
            } else if (species == 7) {
                (_Pet,) = _EvolveID16RQ(1,_Pet);
            } else if (species == 8) {
                (_Pet,) = _EvolveID17RQ(1,_Pet);
            } else if (species == 9) {
                (_Pet,) = _EvolveID19RQ(1,_Pet);
            }
            
        } else if (_Pet.attribute.stage == 2 && (_returnLevel(_Pet.exp) >= 18) && _Pet.time.evolutiontime < timenow) { //rookie to mature and reach level 18
            if        (species == 10){ //link to above
                (_Pet,) = _EvolveID23RQ(1,_Pet);
            } else if (species == 14) {
                (_Pet,) = _EvolveID32RQ(1,_Pet);
            } else if (species == 16) {
                (_Pet,) = _EvolveID29RQ(1,_Pet);
            } else if (species == 17) {
                (_Pet,) = _EvolveID37RQ(1,_Pet);
            } else if (species == 19) {
                (_Pet,) = _EvolveID27RQ(1,_Pet);
            }
            
        } else if (_Pet.attribute.stage == 3 && (_returnLevel(_Pet.exp) >= 20) && _Pet.time.evolutiontime < timenow) { //mature to perfect and reach level 20
            if        (species == 23){ //link to above
                (_Pet,) = _EvolveID44RQ(1,_Pet);
            } else if (species == 32) {
                (_Pet,) = _EvolveID53RQ(1,_Pet);
            } else if (species == 29) {
                (_Pet,) = _EvolveID51RQ(1,_Pet);
            } else if (species == 37) {
                (_Pet,) = _EvolveID54RQ(1,_Pet);
            } else if (species == 27) {
                (_Pet,) = _EvolveID49RQ(1,_Pet);
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
      function _EvolveID11RQ(uint rand, A.Pets memory _Pet) private view //Chipper
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<3,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.intellegence>=50   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 11; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,42000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,43);
            _Pet.power.agility = add16B999L(_Pet.power.agility,44);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,65);
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
      function _EvolveID12RQ(uint rand, A.Pets memory _Pet) private view //Tairan
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<5,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.intellegence<50   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 12; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,70000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,66);
            _Pet.power.agility = add16B999L(_Pet.power.agility,33);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,27);
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
      function _EvolveID13RQ(uint rand, A.Pets memory _Pet) private view //Fluffy
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<7,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.agility>=50 &&
            _Pet.attribute.happiness>=150   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 13; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,35000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,37);
            _Pet.power.agility = add16B999L(_Pet.power.agility,85);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,44);
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
      function _EvolveID14RQ(uint rand, A.Pets memory _Pet) private view //Salamandra
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<9,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.strength>=50   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 14; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,75000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,67);
            _Pet.power.agility = add16B999L(_Pet.power.agility,30);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,25);
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
      function _EvolveID15RQ(uint rand, A.Pets memory _Pet) private view //Dove
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<11,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.agility>=50 &&
            _Pet.attribute.weight<1600   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 15; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,40000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,30);
            _Pet.power.agility = add16B999L(_Pet.power.agility,82);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,44);
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
      function _EvolveID18RQ(uint rand, A.Pets memory _Pet) private view //IIO-der
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<17,4,0) < 3 && //60% chance to evolve to this
            _Pet.attribute.weight>1000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 18; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,65000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,55);
            _Pet.power.agility = add16B999L(_Pet.power.agility,30);
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
      function _EvolveID19RQ(uint rand, A.Pets memory _Pet) private view //Liquid Jiggle
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<19,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>=50000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 19; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,75000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,44);
            _Pet.power.agility = add16B999L(_Pet.power.agility,44);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,44);
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
      function _EvolveID20RQ(uint rand, A.Pets memory _Pet) private view //Fire Jiggle
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<21,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.strength>=50   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 20; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,44000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,75);
            _Pet.power.agility = add16B999L(_Pet.power.agility,44);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,44);
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
      function _EvolveID21RQ(uint rand, A.Pets memory _Pet) private view //Shadow Jiggle
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<23,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.agility>=50 &&
            _Pet.attribute.discipline<50   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 21; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,44000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,44);
            _Pet.power.agility = add16B999L(_Pet.power.agility,75);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,44);
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
      function _EvolveID22RQ(uint rand, A.Pets memory _Pet) private view //Nature Jiggle
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<25,4,0) < 3 && //60% chance to evolve to this
            _Pet.attribute.happiness>=125   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 22; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,44000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,44);
            _Pet.power.agility = add16B999L(_Pet.power.agility,44);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,75);
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
      function _EvolveID24RQ(uint rand, A.Pets memory _Pet) private view //Monja
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<29,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.agility>=150 &&
            _Pet.power.strength>=150   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 24; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,85000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,101);
            _Pet.power.agility = add16B999L(_Pet.power.agility,99);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,98);
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
      function _EvolveID25RQ(uint rand, A.Pets memory _Pet) private view //Flashsaurus
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<31,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.agility>=200 &&
            _Pet.attribute.weight< 21000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 25; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,75000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,55);
            _Pet.power.agility = add16B999L(_Pet.power.agility,200);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,45);
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
      function _EvolveID26RQ(uint rand, A.Pets memory _Pet) private view //Glacieo
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<33,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.strength>=180 &&
            _Pet.attribute.weight>21000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 26; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,105000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,158);
            _Pet.power.agility = add16B999L(_Pet.power.agility,88);
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
      function _EvolveID27RQ(uint rand, A.Pets memory _Pet) private view //Dr. Liquid
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<35,4,0) < 3 && //60% chance to evolve to this
            _Pet.attribute.weight<22000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 27; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,110000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,110);
            _Pet.power.agility = add16B999L(_Pet.power.agility,110);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,110);
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
      function _EvolveID28RQ(uint rand, A.Pets memory _Pet) private view //Crabtron
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<37,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>=180000 &&
            _Pet.attribute.weight>=25000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 28; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,170000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,106);
            _Pet.power.agility = add16B999L(_Pet.power.agility,44);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,80);
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
      function _EvolveID29RQ(uint rand, A.Pets memory _Pet) private view //Gagobat
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<39,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.agility>=120 &&
            _Pet.attribute.discipline<50 &&
            _Pet.attribute.weight<5000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 29; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,98000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,75);
            _Pet.power.agility = add16B999L(_Pet.power.agility,110);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,80);
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
      function _EvolveID31RQ(uint rand, A.Pets memory _Pet) private view //Petalizard
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<43,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>=150000 &&
            _Pet.attribute.happiness>120 &&
            _Pet.attribute.weight>=18000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 31; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,112000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,97);
            _Pet.power.agility = add16B999L(_Pet.power.agility,99);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,86);
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
      function _EvolveID32RQ(uint rand, A.Pets memory _Pet) private view //Bonefang
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<45,4,0) < 3 && //60% chance to evolve to this
            _Pet.attribute.discipline<20 &&
            _Pet.attribute.weight<23000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 32; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,79000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,98);
            _Pet.power.agility = add16B999L(_Pet.power.agility,121);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,88);
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
      function _EvolveID33RQ(uint rand, A.Pets memory _Pet) private view //Bloomtail
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<47,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.intellegence>=200 &&
            _Pet.attribute.happiness>200 &&
            _Pet.attribute.weight<7000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 33; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,81000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,44);
            _Pet.power.agility = add16B999L(_Pet.power.agility,98);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,178);
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
      function _EvolveID34RQ(uint rand, A.Pets memory _Pet) private view //Clockabit
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<49,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>=180000 &&
            _Pet.attribute.discipline<80 &&
            _Pet.attribute.weight>=21000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 34; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,132000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,69);
            _Pet.power.agility = add16B999L(_Pet.power.agility,100);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,122);
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
      function _EvolveID35RQ(uint rand, A.Pets memory _Pet) private view //Baba
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<51,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>=180000 &&
            _Pet.power.strength>=150 &&
            _Pet.attribute.weight>=33000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 35; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,160000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,180);
            _Pet.power.agility = add16B999L(_Pet.power.agility,22);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,63);
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
      function _EvolveID36RQ(uint rand, A.Pets memory _Pet) private view //Wastemon
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<53,4,0) < 3 && //60% chance to evolve to this
            _Pet.attribute.discipline<50 &&
            _Pet.attribute.happiness<50   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 36; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,69000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,69);
            _Pet.power.agility = add16B999L(_Pet.power.agility,69);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,69);
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
      function _EvolveID38RQ(uint rand, A.Pets memory _Pet) private view //Frog Go
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<57,4,0) < 3 && //60% chance to evolve to this
            _Pet.attribute.happiness>=125   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 38; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,87000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,88);
            _Pet.power.agility = add16B999L(_Pet.power.agility,95);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,129);
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
      function _EvolveID39RQ(uint rand, A.Pets memory _Pet) private view //Samuraikid
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<59,4,0) < 3 && //60% chance to evolve to this
            _returnLevel(_Pet.exp)>23 &&
            _Pet.attribute.discipline<100 &&
            _Pet.attribute.happiness<20   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 39; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,78000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,130);
            _Pet.power.agility = add16B999L(_Pet.power.agility,122);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,97);
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
      function _EvolveID40RQ(uint rand, A.Pets memory _Pet) private view //Herdmaster
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<61,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>=200000 &&
            _Pet.power.strength>=180 &&
            _returnLevel(_Pet.exp)>23 &&
            _Pet.attribute.discipline>100 &&
            _Pet.attribute.weight>35000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 40; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,134000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,124);
            _Pet.power.agility = add16B999L(_Pet.power.agility,87);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,78);
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
      function _EvolveID41RQ(uint rand, A.Pets memory _Pet) private view //Archangel
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<63,4,0) < 3 && //60% chance to evolve to this
            _returnLevel(_Pet.exp)>23 &&
            _Pet.attribute.discipline>240   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 41; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,110000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,78);
            _Pet.power.agility = add16B999L(_Pet.power.agility,112);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,135);
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
      function _EvolveID42RQ(uint rand, A.Pets memory _Pet) private view //Fallen Angel
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<65,4,0) < 3 && //60% chance to evolve to this
            _returnLevel(_Pet.exp)>23 &&
            _Pet.attribute.discipline<10   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 42; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,98000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,134);
            _Pet.power.agility = add16B999L(_Pet.power.agility,112);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,89);
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
      function _EvolveID43RQ(uint rand, A.Pets memory _Pet) private view //Goliachimp
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<67,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>500000 &&
            _Pet.power.strength>350 &&
            _Pet.attribute.discipline>150   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 43; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,200000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,280);
            _Pet.power.agility = add16B999L(_Pet.power.agility,133);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,144);
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
      function _EvolveID45RQ(uint rand, A.Pets memory _Pet) private view //Zomplant
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<71,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>550000 &&
            _Pet.power.strength>300 &&
            _Pet.power.agility<300 &&
            _Pet.attribute.discipline<20   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 45; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,280000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,233);
            _Pet.power.agility = add16B999L(_Pet.power.agility,95);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,95);
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
      function _EvolveID46RQ(uint rand, A.Pets memory _Pet) private view //Cocc-1001
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<73,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>600000 &&
            _Pet.power.strength>300 &&
            _Pet.power.intellegence>300 &&
            _Pet.attribute.weight>80000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 46; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,220000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,233);
            _Pet.power.agility = add16B999L(_Pet.power.agility,122);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,225);
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
      function _EvolveID47RQ(uint rand, A.Pets memory _Pet) private view //Kingsaurus
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<75,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>450000 &&
            _Pet.power.strength>400 &&
            _Pet.power.intellegence<300 &&
            _Pet.attribute.weight>110000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 47; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,210000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,250);
            _Pet.power.agility = add16B999L(_Pet.power.agility,136);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,120);
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
      function _EvolveID48RQ(uint rand, A.Pets memory _Pet) private view //Beezoka
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<77,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>300000 &&
            _Pet.power.agility>350 &&
            _Pet.power.intellegence>300 &&
            _Pet.attribute.weight<15000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 48; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,180000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,188);
            _Pet.power.agility = add16B999L(_Pet.power.agility,233);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,177);
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
      function _EvolveID49RQ(uint rand, A.Pets memory _Pet) private view //Elemental
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<79,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>400000 &&
            _Pet.power.strength>300 &&
            _Pet.power.agility>300 &&
            _Pet.power.intellegence>300   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 49; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,210000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,210);
            _Pet.power.agility = add16B999L(_Pet.power.agility,210);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,210);
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
      function _EvolveID50RQ(uint rand, A.Pets memory _Pet) private view //Farie Guardian
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<81,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>300000 &&
            _Pet.power.agility>350 &&
            _Pet.power.intellegence>350 &&
            _Pet.attribute.weight<11000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 50; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,132000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,143);
            _Pet.power.agility = add16B999L(_Pet.power.agility,237);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,267);
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
      function _EvolveID51RQ(uint rand, A.Pets memory _Pet) private view //Ascendant
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<83,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>440000 &&
            _Pet.power.intellegence>450 &&
            _returnLevel(_Pet.exp)>23   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 51; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,200000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,190);
            _Pet.power.agility = add16B999L(_Pet.power.agility,189);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,222);
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
      function _EvolveID52RQ(uint rand, A.Pets memory _Pet) private view //Lady Naga
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<85,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>450000 &&
            _Pet.power.strength>350 &&
            _Pet.power.intellegence>300 &&
            _Pet.attribute.happiness>200   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 52; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,154000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,188);
            _Pet.power.agility = add16B999L(_Pet.power.agility,176);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,203);
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
      function _EvolveID53RQ(uint rand, A.Pets memory _Pet) private view //Chukita Hound
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<87,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>480000 &&
            _Pet.power.strength>330 &&
            _Pet.power.intellegence>300 &&
            _Pet.attribute.discipline>200   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 53; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,200000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,180);
            _Pet.power.agility = add16B999L(_Pet.power.agility,210);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,175);
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
      function _EvolveID55RQ(uint rand, A.Pets memory _Pet) private view //Ashmon
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<91,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>300000 &&
            _Pet.power.strength>300 &&
            _Pet.power.agility>300 &&
            _Pet.power.intellegence>300 &&
            _Pet.attribute.happiness>150   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 55; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,300000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,250);
            _Pet.power.agility = add16B999L(_Pet.power.agility,200);
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
      function _EvolveID56RQ(uint rand, A.Pets memory _Pet) private view //Fantom King
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<93,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>350000 &&
            _Pet.power.intellegence>450 &&
            _Pet.attribute.weight>55000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 56; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,167000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,188);
            _Pet.power.agility = add16B999L(_Pet.power.agility,176);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,269);
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
      function _EvolveID58RQ(uint rand, A.Pets memory _Pet) private view //Shadowpaw
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<97,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>320000 &&
            _Pet.power.agility>300 &&
            _Pet.power.intellegence>300 &&
            _Pet.attribute.happiness>200   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 58; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,150000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,180);
            _Pet.power.agility = add16B999L(_Pet.power.agility,210);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,195);
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
      function _EvolveID59RQ(uint rand, A.Pets memory _Pet) private view //Serene Uman
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<99,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>350000 &&
            _Pet.power.strength<250 &&
            _Pet.power.intellegence>450 &&
            _Pet.attribute.weight<14000 &&
            _Pet.attribute.discipline>200   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 59; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,143000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,156);
            _Pet.power.agility = add16B999L(_Pet.power.agility,198);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,290);
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
      function _EvolveID60RQ(uint rand, A.Pets memory _Pet) private view //Drake
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<101,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>450000 &&
            _Pet.power.strength>350 &&
            _Pet.power.intellegence>300 &&
            _Pet.attribute.weight>90000   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 60; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,210000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,200);
            _Pet.power.agility = add16B999L(_Pet.power.agility,200);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,167);
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
      function _EvolveID61RQ(uint rand, A.Pets memory _Pet) private view //Dreamoth
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<103,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>300000 &&
            _Pet.power.agility<300 &&
            _Pet.power.intellegence>450 &&
            _Pet.attribute.happiness>200   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 61; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,189000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,134);
            _Pet.power.agility = add16B999L(_Pet.power.agility,124);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,286);
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
      function _EvolveID62RQ(uint rand, A.Pets memory _Pet) private view //Gundam
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<105,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>350000 &&
            _Pet.power.intellegence>450 &&
            _Pet.attribute.discipline<20   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 62; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,175000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,184);
            _Pet.power.agility = add16B999L(_Pet.power.agility,203);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,235);
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
      function _EvolveID63RQ(uint rand, A.Pets memory _Pet) private view //Ancient Dragon
                                returns (A.Pets memory, bool MeetRQ){
        if (_RandNumb(rand<<107,4,0) < 3 && //60% chance to evolve to this
            _Pet.power.hitpoints>500000 &&
            _Pet.power.strength>450 &&
            _Pet.power.agility>300 &&
            _Pet.attribute.weight>100000 &&
            _returnLevel(_Pet.exp)>55   ) { //check meet evolve condition?
            MeetRQ = true;
            _Pet.species = 63; //set to new species
            //uint8 geneSynapse = add9L(_getGene(_Pet.gene,_Pet.species),1); //increase the geneSynapse based on new species
            //_Pet.gene = _setGene(_Pet.gene,_Pet.species+1,geneSynapse); //order always +1 from Species(start with 0), set it    
            //----evolve bonus
            _Pet.power.hitpoints = add32b(_Pet.power.hitpoints,205000);
            _Pet.power.strength = add16B999L(_Pet.power.strength,224);
            _Pet.power.agility = add16B999L(_Pet.power.agility,225);
            _Pet.power.intellegence = add16B999L(_Pet.power.intellegence,183);
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
