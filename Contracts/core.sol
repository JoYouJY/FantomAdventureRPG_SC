// SPDX-License-Identifier: MIT

pragma solidity ^0.8;
 
import "./myPet.sol";
import "./evolution.sol";

library core {
    uint64 private constant FULL_ENDURANCE = 40 hours;
    uint64 private constant INITIAL_STAMINA = 40 minutes;
    uint64 private constant FULL_STAMINA = 40 minutes;
    uint64 private constant INITIAL_ENDURANCE = 6 hours;
    uint64 private constant lifeGainYouth = 365 days; 
    uint64 private constant YouthtoRookieTime = 10 seconds;



    function _RandNumb(uint _rand, uint32 _maxRand, uint32 _offset) private pure returns (uint32) {
        return uint32(_rand % (_maxRand+1-_offset) + _offset); // e.g. max 7, offset 2, means will get 2~7 randomly
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

   
    //----------------------------------------------


     /**
    * @dev Mint a myPet egg based on a given random number.
    * @param _deRand The random number used to generate the myPet.
    * @return myPet The newly minted myPet.
    */
    function mintEgg(uint _deRand) external pure returns (A.myPets memory myPet) {
        uint8 _randegg = uint8(_RandNumb(_deRand,99,0));
        if (_randegg >= 95) { //5%
            _randegg = 4;
        } else if (_randegg >= 84) { //11%
            _randegg = 3;
        } else if (_randegg >= 56) { //28%
            _randegg = 2;
        } else if (_randegg >= 28) { //28%
            _randegg = 1;
        } else { //28%
            _randegg = 0;
        }
        myPet = A.myPets(
            _randegg, // type of myPet species (egg 0 to 4)
            10**_randegg, // gene
            A.attributes(
                uint8(_RandNumb(_deRand<<8,150,50)), // happiness
                uint8(_RandNumb(_deRand<<16,150,50)), // discipline
                0, // id (will be replaced in main function)
                100, // weight
                0 // stage
            ),
            A.powers(
                1, // hitpoints
                1, // strength
                1, // agility
                1 // intellegence
            ),
            0, // exp
            A.timings(
                0, // deadtime
                0, // endurance
                0, // outgoingtime
                0, // stamina
                0 // evolutiontime
            ),
            [0,0,0], // trait
            [0,0,0], // skill
            0, // status (0 = active)
            uint16(_RandNumb(_deRand<<24,4,0)), // family
            false // shinning (only for evolve, revive reset to false)
        ); 
    }

    function HatchEgg(A.myPets memory _Egg, address _ownerof) 
    external view returns(A.myPets memory myPet) {
        myPet = _Egg;
        require(msg.sender == _ownerof, "xPermission");
        
        require ((myPet.species <=4  //an egg
                || myPet.time.endurance < block.timestamp || myPet.time.deadtime < block.timestamp ) //or dead
                , "xmyPetStatusVspecies"); 
        A.powers memory _pwrs;
        uint64 timenow = uint64(block.timestamp);
        if      (myPet.species==4)   {_pwrs = A.powers(28000,126,26,26);}//Amorp Egg
        else if (myPet.species==3)   {_pwrs = A.powers(47000,135,9,20);} //Mech Egg
        else if (myPet.species==2)   {_pwrs = A.powers(23000,115,38,24);} //Volant Egg
        else if (myPet.species==1)   {_pwrs = A.powers(26000,145,19,10);} //Quaped Egg
        else   /*myPet.species==0*/  {_pwrs = A.powers(24000,118,18,40);} //Biped Egg
        myPet.species = myPet.species + 5;
        myPet.attribute.stage = 1;
        myPet.power = _pwrs;
        myPet.time = A.timings (      timenow+lifeGainYouth, //deadtime
                                        timenow+INITIAL_ENDURANCE, //endurance
                                        0, //frozen time
                                        timenow-INITIAL_STAMINA, //stamina
                                        timenow+YouthtoRookieTime //evolutiontime
                                    ); 
    }

    function FeedmyPet(uint _deRand, A.myPets memory _myPet, uint8 _foodtype,address _ownerof) 
    external view returns(A.myPets memory myPet) { //Foodtype 0 to 5
        myPet = _myPet;
        require (myPet.species >4  //not an egg
                , "xmyPetStatusVspecies"); 
        require(msg.sender == _ownerof, "xPermission");
        uint64 _timenow = uint64(block.timestamp);
        uint64 _full;
        uint32 _weight;
        uint8 _happy;
        if (myPet.time.endurance<_timenow) { //if myPet die of hunger but still has life time
            myPet.time.endurance = _timenow; //revive from hunger
        }
        uint64 _enduranceleft = myPet.time.endurance-_timenow;
        if (myPet.time.deadtime >= _timenow && myPet.time.endurance >= _timenow) { //Alive & Active
            //Choose Your Food :p
            if (_foodtype==6){_full = 9 hours; _weight = 9440; _happy = 10;}//Salmon gain life at main contract! **********
            else if (_foodtype==5){_full = 11 hours; _weight = 3135; _happy = 9;} //big vege
            else if (_foodtype==4){_full = 7 hours; _weight = 1662; _happy = 6;} //mid vege
            else if (_foodtype==3){_full = 3 hours; _weight = 570; _happy = 3;} //grass
            else if (_foodtype==2){_full = 12 hours; _weight = 25200; _happy = 11;} //Wagyu Meat
            else if (_foodtype==1){_full = 8 hours; _weight = 12700; _happy = 8;} //Giant Meat
            else {_full = 4 hours; _weight = 5000; _happy = 5;} // Meat 0
            //Eating
            myPet.attribute.weight = add32b(myPet.attribute.weight,_weight);
            myPet.time.endurance = add64b(myPet.time.endurance,_full);
            if (myPet.time.endurance-_timenow > FULL_ENDURANCE){ //Your myPet has too full
                //myPet.exp = myPet.exp + uint32(10*(_full - (myPet.time.endurance - (_timenow+FULL_ENDURANCE))));
                myPet.time.endurance = _timenow+FULL_ENDURANCE; //cap at FULL_ENDURANCE
                myPet.attribute.happiness = sub8b(myPet.attribute.happiness,1);
            }else { // normal hours, :) happy
                myPet.attribute.happiness = add8b(myPet.attribute.happiness,_happy);
                //myPet.exp = myPet.exp + uint32(10*(_full));
            }
            myPet.exp = myPet.exp + 10*uint32((myPet.time.endurance-_timenow-_enduranceleft));
        } 
        myPet = EVO.checkEvolve(_deRand,myPet);
    }

    function trainmyPet(uint _deRand, A.myPets memory _myPet, uint8 _traintype,address _ownerof) 
        external view returns(A.myPets memory myPet) { //TrainType 0 to 7
        myPet = _myPet;
        require (myPet.species >4  //not an egg
                , "xmyPetStatusVspecies"); 
        require(msg.sender == _ownerof, "xPermission");
        uint64 _timenow = uint64(block.timestamp);
        //trait start first to prevent stack too deep, limitation of Solidity
        if (myPet.time.deadtime > _timenow && myPet.time.endurance > _timenow //myPet still alive
            && myPet.status == 0) { //Alive & Active
            uint64 _stamina = sub64b(_timenow,myPet.time.stamina);
            uint32 _level = _returnLevel(_myPet.exp);
            uint64 _tiredness;
            uint32 _weightloss;
            uint8 _happy;
            uint8 _discipline;
            
            A.powers memory _pwrstemp;
            //Choose Your training routing :p
            if      (_traintype==13){_tiredness = 2 minutes; _weightloss = 600; _happy = 1; _discipline = 3; //reduce HAP, gain DIS
                 _pwrstemp.hitpoints=2000; _pwrstemp.intellegence=10;}//Exercises
            else if (_traintype==12){_tiredness = 2 minutes; _weightloss = 2100; _happy = 1; _discipline = 3; //reduce HAP, gain DIS
                  _pwrstemp.strength=1; _pwrstemp.agility=11;}//Exercises
            else if (_traintype==11){_tiredness = 2 minutes; _weightloss = 1520; _happy = 1; _discipline = 3; //reduce HAP, gain DIS
                 _pwrstemp.strength=11; _pwrstemp.agility=1; _pwrstemp.intellegence=1;}//Exercises
            else if (_traintype==10){_tiredness = 2 minutes; _weightloss = 1920; _happy = 1; _discipline = 3; //reduce HAP, gain DIS
                 _pwrstemp.hitpoints=11000; _pwrstemp.strength=1; _pwrstemp.intellegence=1;}//Exercises
            else if (_traintype==9){_tiredness = 0 minutes; _weightloss = 0; _happy = 0; _discipline = 0; //nothing
                    }
            else if (_traintype==8){_tiredness = 0 minutes; _weightloss = 0; _happy = 0; _discipline = 0; //nothing
                    }
            else if (_traintype==7){_tiredness = 25 minutes; _weightloss = 6251; _happy = 12; _discipline = 26; //reduce HAP, gain DIS
                 _pwrstemp.hitpoints=36000; _pwrstemp.intellegence=109;}//Courses
            else if (_traintype==6){_tiredness = 25 minutes; _weightloss = 23814; _happy = 12; _discipline = 25; //reduce HAP, gain DIS
                  _pwrstemp.strength=36; _pwrstemp.agility=110;}//Running Machine
            else if (_traintype==5){_tiredness = 25 minutes; _weightloss = 17320; _happy = 12; _discipline = 25; //reduce HAP, gain DIS
                 _pwrstemp.strength=105; _pwrstemp.agility=18; _pwrstemp.intellegence=22;}//Wooden Dummy
            else if (_traintype==4){_tiredness = 25 minutes; _weightloss = 11753; _happy = 13; _discipline = 25; //reduce HAP, gain DIS
                  _pwrstemp.hitpoints=107520; _pwrstemp.strength=25; _pwrstemp.intellegence=15;}//sit under waterfall
            else if (_traintype==3){_tiredness = 8 minutes; _weightloss = 2000; _happy = 2; _discipline = 10; //reduce HAP, gain DIS
                 _pwrstemp.hitpoints=6800; _pwrstemp.intellegence=40;}//black board
            else if (_traintype==2){_tiredness = 8 minutes; _weightloss = 7200; _happy = 2; _discipline = 9; //reduce HAP, gain DIS
                  _pwrstemp.strength=4; _pwrstemp.agility=42;}//Sprint
            else if (_traintype==1){_tiredness = 8 minutes; _weightloss = 5420; _happy = 2; _discipline = 9; //reduce HAP, gain DIS
                 _pwrstemp.strength=45; _pwrstemp.agility=1; _pwrstemp.intellegence=1;}//Punching bag
            else /*if (_traintype==0)*/{_tiredness = 8 minutes; _weightloss = 7600; _happy = 3; _discipline = 9; //reduce HAP, gain DIS
                 _pwrstemp.hitpoints=41200; _pwrstemp.strength=3; _pwrstemp.intellegence=1;}//Push bolder
            require(_stamina >= _tiredness, "too tired");
            //traits affect
            (_pwrstemp, _happy, _discipline) = traitAddStateTraining(_tiredness, myPet.trait,_pwrstemp, _happy, _discipline);

            //training 
            myPet.power.hitpoints = add32B999999L(myPet.power.hitpoints,_pwrstemp.hitpoints*_level/255);
            myPet.power.strength = add16B999L(myPet.power.strength,uint16(_pwrstemp.strength*_level/255));
            myPet.power.agility = add16B999L(myPet.power.agility,uint16(_pwrstemp.agility*_level/255));
            myPet.power.intellegence = add16B999L(myPet.power.intellegence,uint16(_pwrstemp.intellegence*_level/255));
            myPet.attribute.happiness = sub8b(myPet.attribute.happiness,_happy);
            myPet.attribute.discipline = add8b(myPet.attribute.discipline,_discipline);
            myPet.attribute.weight = sub32b(myPet.attribute.weight,_weightloss);
            if (myPet.attribute.weight == 0) {myPet.attribute.weight = 100;} //minimum weight
            //EXP
            myPet.exp = myPet.exp + 32121*uint32(_tiredness/1 minutes);
            //=======capped by FULL STAMINA=======//
            _stamina = sub64b(_stamina, _tiredness);
            if ( _stamina > (FULL_STAMINA-_tiredness)) { 
                myPet.time.stamina = _timenow - FULL_STAMINA+_tiredness;
            } else if (_stamina == 0) {//=0 in unsigned data = stamina go negative! TOO TIRED!
                myPet.time.stamina = add64b(myPet.time.stamina,_tiredness);
            } else {
                myPet.time.stamina = add64b(myPet.time.stamina,_tiredness);
            }
            //============
        }
        myPet = EVO.checkEvolve(_deRand<<18,myPet);
    }

    function traitAddStateTraining(uint64 _tiredness, uint8[3] memory _traits, A.powers memory _pwrstemp, uint8 _happy, uint8 _discipline) 
    private pure returns(A.powers memory pwrstemp, uint8 happy, uint8 discipline){
        pwrstemp = _pwrstemp;
        happy = _happy;
        discipline = _discipline;
        uint16 _bonushr =  uint16(_tiredness/1 minutes); //tireness from Praise and Scold is 0, so Traits wont adds anything
        for (uint256 i; i < 3; i++) {
                if      (_traits[i] == 1) {pwrstemp.hitpoints = pwrstemp.hitpoints + 800*_bonushr;} //Tough
                else if (_traits[i] == 2) {pwrstemp.strength= pwrstemp.strength +(8*_bonushr)/10;} //Brawler
                else if (_traits[i] == 3) {pwrstemp.agility =pwrstemp.agility +(8*_bonushr)/10;} //Nimble
                else if (_traits[i] == 4) {pwrstemp.intellegence = _pwrstemp.intellegence+(8*_bonushr)/10;} //Smart
                //battletrait 5,6
                else if (_traits[i] == 7) {happy = happy+(15*uint8(_bonushr))/10;} //Hardworking
                else if (_traits[i] == 8) {discipline = discipline+(15*uint8(_bonushr))/10;} //Serious
                //battletrait 9,10,11
                else if (_traits[i] == 12) {pwrstemp.strength = pwrstemp.strength +(3*_bonushr)/10;} //Lonely
                else if (_traits[i] == 13) {pwrstemp.strength = pwrstemp.strength +(4*_bonushr)/10;} //Bashful
                else if (_traits[i] == 14) {pwrstemp.strength = pwrstemp.strength +(5*_bonushr)/10;} //Adamant
                else if (_traits[i] == 15) {pwrstemp.strength = pwrstemp.strength +(6*_bonushr)/10;} //Naughty
                else if (_traits[i] == 16) {pwrstemp.strength = pwrstemp.strength +(7*_bonushr)/10;} //Brave
                else if (_traits[i] == 17) {pwrstemp.agility = pwrstemp.agility +(3*_bonushr)/10;} //Timid
                else if (_traits[i] == 18) {pwrstemp.agility = pwrstemp.agility +(4*_bonushr)/10;} //Hasty
                else if (_traits[i] == 19) {pwrstemp.agility = pwrstemp.agility +(5*_bonushr)/10;} //Jolly
                else if (_traits[i] == 20) {pwrstemp.agility = pwrstemp.agility +(6*_bonushr)/10;} //Naive
                else if (_traits[i] == 21) {pwrstemp.agility = pwrstemp.agility +(7*_bonushr)/10;} //Quirky
                else if (_traits[i] == 22) {pwrstemp.intellegence = pwrstemp.intellegence +(3*_bonushr)/10;} //Mild
                else if (_traits[i] == 23) {pwrstemp.intellegence = pwrstemp.intellegence +(4*_bonushr)/10;} //Quiet
                else if (_traits[i] == 24) {pwrstemp.intellegence = pwrstemp.intellegence +(5*_bonushr)/10;} //Rash
                else if (_traits[i] == 25) {pwrstemp.intellegence = pwrstemp.intellegence +(6*_bonushr)/10;} //Modest
                else if (_traits[i] == 26) {pwrstemp.intellegence = pwrstemp.intellegence +(7*_bonushr)/10;} //Docile
                else if (_traits[i] == 27) {pwrstemp.hitpoints = pwrstemp.hitpoints + 300*_bonushr;} //Relaxed
                else if (_traits[i] == 28) {pwrstemp.hitpoints = pwrstemp.hitpoints + 400*_bonushr;} //Bold
                else if (_traits[i] == 29) {pwrstemp.hitpoints = pwrstemp.hitpoints + 500*_bonushr;} //Impish
                else if (_traits[i] == 30) {pwrstemp.hitpoints = pwrstemp.hitpoints + 600*_bonushr;} //Lax
                else if (_traits[i] == 31) {pwrstemp.hitpoints = pwrstemp.hitpoints + 700*_bonushr;} //Careful
            }
    }

}





