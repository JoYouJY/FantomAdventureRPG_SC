// SPDX-License-Identifier: MIT

pragma solidity ^0.8;
 
import "./myPet.sol";
import "./evolution.sol";

library core {
    uint64 private constant FULL_ENDURANCE = 24 hours;
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
    /**
    * @dev Mint a Pet egg based on a given random number.
    * @param _deRand The random number used to generate the Pet.
    * @return Pet The newly minted Pet.
    */
    function mintEgg(uint _deRand) external pure returns (A.Pets memory Pet) {
        uint8 _randegg = uint8(_RandNumb(_deRand,2,0));
        if (_randegg >0) {_randegg = _randegg + 1;}
        //33% for each egg
        Pet = A.Pets(
            _randegg, // type of Pet species (egg 0 to 4)
            10**_randegg, // gene
            A.attributes(
                uint8(_RandNumb((_deRand>>8)+(_deRand>>1),150,50)), // happiness
                uint8(_RandNumb((_deRand>>16)+(_deRand>>1),150,50)), // discipline
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
            uint16(_RandNumb((_deRand>>24)+(_deRand>>1),4,0)), // family
            false // shinning (only for evolve, revive reset to false)
        ); 
    }

    function HatchEgg(A.Pets memory _Egg, address _ownerof) //due to story change in last minutes, change into BOX
    external view returns(A.Pets memory Pet) {
        Pet = _Egg;
        require(msg.sender == _ownerof, "xPermission");
        
        require ((Pet.species <=4 ) 
                , "xPetStatusVspecies"); 
        A.powers memory _pwrs;
        uint64 timenow = uint64(block.timestamp);
        if      (Pet.species==4)   {_pwrs = A.powers(28000,76,26,26);}
        else if (Pet.species==3)   {_pwrs = A.powers(47000,85,9,20);} 
        else if (Pet.species==2)   {_pwrs = A.powers(23000,65,38,24);} 
        else if (Pet.species==1)   {_pwrs = A.powers(26000,95,19,10);} 
        else   /*Pet.species==0*/  {_pwrs = A.powers(24000,68,18,40);} 
        Pet.species = Pet.species + 5;
        Pet.attribute.stage = 1;
        Pet.power = _pwrs;
        Pet.time = A.timings (      timenow+lifeGainYouth, //deadtime
                                        timenow+INITIAL_ENDURANCE, //endurance
                                        0, //frozen time
                                        timenow-INITIAL_STAMINA, //stamina
                                        timenow+YouthtoRookieTime //evolutiontime
                                    ); 
    }

    function FeedPet(A.Pets memory _Pet, uint8 _foodtype,address _ownerof) 
    external view returns(A.Pets memory Pet) { //Foodtype 0 to 5
        Pet = _Pet;
        require (Pet.species >4  //not an egg
                , "xPetStatusVspecies"); 
        require(msg.sender == _ownerof, "xPermission");
        uint64 _timenow = uint64(block.timestamp);
        uint64 _full;
        uint32 _weight;
        uint8 _happy;
        if (Pet.time.endurance<_timenow) { //if Pet die of hunger but still has life time
            Pet.time.endurance = _timenow; //revive from hunger then..
        }
        uint64 _enduranceleft = Pet.time.endurance-_timenow;
        if (Pet.time.deadtime >= _timenow && Pet.time.endurance >= _timenow) { //Alive & Active
            //Choose Your Food :p
            if (_foodtype==6){_full = 9 hours; _weight = 9440; _happy = 10;}
            else if (_foodtype==5){_full = 11 hours; _weight = 3135; _happy = 9;} 
            else if (_foodtype==4){_full = 7 hours; _weight = 1662; _happy = 6;} 
            else if (_foodtype==3){_full = 3 hours; _weight = 570; _happy = 3;} 
            else if (_foodtype==2){_full = 12 hours; _weight = 25200; _happy = 11;} 
            else if (_foodtype==1){_full = 8 hours; _weight = 12700; _happy = 8;} 
            else {_full = 4 hours; _weight = 5000; _happy = 5;} 
            //Eating
            Pet.attribute.weight = add32b(Pet.attribute.weight,_weight);
            Pet.time.endurance = add64b(Pet.time.endurance,_full);
            if (Pet.time.endurance-_timenow > FULL_ENDURANCE){ //Your Pet has too full
                Pet.time.endurance = _timenow+FULL_ENDURANCE; //cap at FULL_ENDURANCE
                Pet.attribute.happiness = sub8b(Pet.attribute.happiness,1);
            }else { // normal hours, :) happy
                Pet.attribute.happiness = add8b(Pet.attribute.happiness,_happy);
                //Pet.exp = Pet.exp + uint32(10*(_full));
            }
            Pet.exp = Pet.exp + 89*uint32((Pet.time.endurance-_timenow-_enduranceleft));
        } 
        Pet = EVO.checkEvolve(Pet);
    }

    function trainPet(A.Pets memory _Pet, uint8 _traintype,address _ownerof) 
        external view returns(A.Pets memory Pet) { //TrainType 0 to 7
        Pet = _Pet;
        require (Pet.species >4  //not an egg
                , "xPetStatusVspecies"); 
        require(msg.sender == _ownerof, "xPermission");
        uint64 _timenow = uint64(block.timestamp);
        //trait start first to prevent stack too deep, limitation of Solidity
        if (Pet.time.deadtime > _timenow && Pet.time.endurance > _timenow //Pet still alive
            && Pet.status == 0) { //Alive & Active
            uint64 _stamina = sub64b(_timenow,Pet.time.stamina);
            uint64 _tiredness;
            uint32 _weightloss;
            uint8 _happy;
            uint8 _discipline;
            
            A.powers memory _pwrstemp;
            //Choose Your training routing :p
            if      (_traintype==13){_tiredness = 2 minutes; _weightloss = 600; _happy = 1; _discipline = 3; //reduce HAP, gain DIS
                 _pwrstemp.hitpoints=4000; _pwrstemp.intellegence=30;}//Exercises
            else if (_traintype==12){_tiredness = 2 minutes; _weightloss = 2100; _happy = 1; _discipline = 3; //reduce HAP, gain DIS
                  _pwrstemp.strength=4; _pwrstemp.agility=30;}//Exercises
            else if (_traintype==11){_tiredness = 2 minutes; _weightloss = 1520; _happy = 1; _discipline = 3; //reduce HAP, gain DIS
                 _pwrstemp.strength=30; _pwrstemp.agility=2; _pwrstemp.intellegence=2;}//Exercises
            else if (_traintype==10){_tiredness = 2 minutes; _weightloss = 1920; _happy = 1; _discipline = 3; //reduce HAP, gain DIS
                 _pwrstemp.hitpoints=30000; _pwrstemp.strength=2; _pwrstemp.intellegence=2;}//Exercises
            else if (_traintype==9){_tiredness = 0 minutes; _weightloss = 0; _happy = 0; _discipline = 0; //nothing
                    }
            else if (_traintype==8){_tiredness = 0 minutes; _weightloss = 0; _happy = 0; _discipline = 0; //nothing
                    }
            else if (_traintype==7){_tiredness = 25 minutes; _weightloss = 6251; _happy = 12; _discipline = 26; //reduce HAP, gain DIS
                 _pwrstemp.hitpoints=145000; _pwrstemp.intellegence=280;}//Courses
            else if (_traintype==6){_tiredness = 25 minutes; _weightloss = 23814; _happy = 12; _discipline = 25; //reduce HAP, gain DIS
                  _pwrstemp.strength=100; _pwrstemp.agility=325;}//Running Machine
            else if (_traintype==5){_tiredness = 25 minutes; _weightloss = 17320; _happy = 12; _discipline = 25; //reduce HAP, gain DIS
                 _pwrstemp.strength=305; _pwrstemp.agility=55; _pwrstemp.intellegence=65;}//Wooden Dummy
            else if (_traintype==4){_tiredness = 25 minutes; _weightloss = 11753; _happy = 13; _discipline = 25; //reduce HAP, gain DIS
                  _pwrstemp.hitpoints=305000; _pwrstemp.strength=65; _pwrstemp.intellegence=55;}//sit under waterfall
            else if (_traintype==3){_tiredness = 8 minutes; _weightloss = 2000; _happy = 2; _discipline = 10; //reduce HAP, gain DIS
                 _pwrstemp.hitpoints=36000; _pwrstemp.intellegence=100;}//black board
            else if (_traintype==2){_tiredness = 8 minutes; _weightloss = 7200; _happy = 2; _discipline = 9; //reduce HAP, gain DIS
                  _pwrstemp.strength=26; _pwrstemp.agility=110;}//Sprint
            else if (_traintype==1){_tiredness = 8 minutes; _weightloss = 5420; _happy = 2; _discipline = 9; //reduce HAP, gain DIS
                 _pwrstemp.strength=115; _pwrstemp.agility=5; _pwrstemp.intellegence=16;}//Punching bag
            else /*if (_traintype==0)*/{_tiredness = 8 minutes; _weightloss = 7600; _happy = 3; _discipline = 9; //reduce HAP, gain DIS
                 _pwrstemp.hitpoints=116000; _pwrstemp.strength=10; _pwrstemp.intellegence=10;}//Push bolder
            require(_stamina >= _tiredness, "too tired");
            //traits affect
            (_pwrstemp, _happy, _discipline) = traitAddStateTraining(_tiredness, Pet.trait,_pwrstemp, _happy, _discipline);

            //training 
            Pet.power.hitpoints = add32B999999L(Pet.power.hitpoints,_pwrstemp.hitpoints );
            Pet.power.strength = add16B999L(Pet.power.strength,_pwrstemp.strength );
            Pet.power.agility = add16B999L(Pet.power.agility,_pwrstemp.agility );
            Pet.power.intellegence = add16B999L(Pet.power.intellegence,_pwrstemp.intellegence );
            Pet.attribute.happiness = sub8b(Pet.attribute.happiness,_happy);
            Pet.attribute.discipline = add8b(Pet.attribute.discipline,_discipline);
            Pet.attribute.weight = sub32b(Pet.attribute.weight,_weightloss);
            if (Pet.attribute.weight == 0) {Pet.attribute.weight = 100;} //minimum weight
            //EXP
            Pet.exp = Pet.exp + 320000*uint32(_tiredness/1 minutes);
            //=======capped by FULL STAMINA=======//
            _stamina = sub64b(_stamina, _tiredness);
            if ( _stamina > (FULL_STAMINA-_tiredness)) { 
                Pet.time.stamina = _timenow - FULL_STAMINA+_tiredness;
            } else if (_stamina == 0) {//=0 in unsigned data = stamina go negative! TOO TIRED!
                Pet.time.stamina = add64b(Pet.time.stamina,_tiredness);
            } else {
                Pet.time.stamina = add64b(Pet.time.stamina,_tiredness);
            }
            //============
        }
        Pet = EVO.checkEvolve(Pet);
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

    function battlingPet(uint8 rank, uint rand) external pure returns(A.Pets memory _BattlingPet) {
        //rank 0 = stage1, 1= stage2, 2= stage3, 3=stage4 3->8->17->37
        _BattlingPet.attribute.id = 10001;
        _BattlingPet.attribute.stage = rank+1;
        _BattlingPet.family = uint16(_RandNumb((rand>>4)+(rand>>1),4,0));
        if (rank ==0 ) { 
            _BattlingPet.species = 8;
            _BattlingPet.attribute.weight = _RandNumb((rand>>5)+(rand>>1),2500,1000);
            _BattlingPet.power.hitpoints = _RandNumb((rand>>21)+(rand>>1),40000,10000);
            _BattlingPet.power.strength = uint16(_RandNumb((rand>>41)+(rand>>1),50,40));
            _BattlingPet.power.agility = uint16(_RandNumb((rand>>51)+(rand>>1),50,10));
            _BattlingPet.power.intellegence = uint16(_RandNumb((rand>>61)+(rand>>1),50,10));
        } else if (rank == 1) {
            _BattlingPet.species = 17;
            _BattlingPet.attribute.weight = _RandNumb((rand>>5)+(rand>>1),4500,1500);
            _BattlingPet.power.hitpoints = _RandNumb((rand>>21)+(rand>>1),130000,5000);
            _BattlingPet.power.strength = uint16(_RandNumb((rand>>41)+(rand>>1),130,95));
            _BattlingPet.power.agility = uint16(_RandNumb((rand>>51)+(rand>>1),130,55));
            _BattlingPet.power.intellegence = uint16(_RandNumb((rand>>61)+(rand>>1),130,55));
            _BattlingPet.skill = [17,0,0];
        } else if (rank == 2) {
            _BattlingPet.species = 37; 
            _BattlingPet.attribute.weight = _RandNumb((rand>>5)+(rand>>1),17500,1500);
            _BattlingPet.power.hitpoints = _RandNumb((rand>>21)+(rand>>1),420000,145000);
            _BattlingPet.power.strength = uint16(_RandNumb((rand>>41)+(rand>>1),350,195));
            _BattlingPet.power.agility = uint16(_RandNumb((rand>>51)+(rand>>1),350,155));
            _BattlingPet.power.intellegence = uint16(_RandNumb((rand>>61)+(rand>>1),450,155));
            _BattlingPet.skill = [17,37,0];    
        } else /*if (rank == 3)*/{
            _BattlingPet.species = 54;
            _BattlingPet.attribute.weight = _RandNumb((rand>>5)+(rand>>1),25000,1500);
            _BattlingPet.power.hitpoints = _RandNumb((rand>>21)+(rand>>1),800000,275000);
            _BattlingPet.power.strength = uint16(_RandNumb((rand>>41)+(rand>>1),590,295));
            _BattlingPet.power.agility = uint16(_RandNumb((rand>>51)+(rand>>1),590,275));
            _BattlingPet.power.intellegence = uint16(_RandNumb((rand>>61)+(rand>>1),790,275));
            _BattlingPet.skill = [17,37,54];   
        }
    }

    function TowerPet(uint32 TowerLevel, uint _deRand) external pure returns(A.Pets memory _TowerPet, uint8[4] memory _chances, uint8 _nextTowerLevel) {
        //rank 0 = stage1, 1= stage2, 2= stage3, 3=stage4
        _TowerPet.attribute.id = 10001;
        //TowerLevel 1~20 = level1, 10 level max. so stage 1 to 4, 2.5 stage each.
        //Towerlevel/41 = stage, max TowerLevel 200, = stage 4 (rounded)
        //e.g. level 1 and 2 = stage 1, 
        _TowerPet.attribute.stage = uint8(((TowerLevel*10)+801)/601); //stage: 1 1 2 2 2 3 3 3 4 4 
        _TowerPet.family = uint8(TowerLevel%5); //0 to 4
        /* chances for 30 Artifact according to rarity
        stage   ratio   15  9   6   30
        1       1       8   1   0   
        2       1       7   2   0   
        3       1       6   2   1   
        4       1       6   2   1   
        5       1       5   3   1   
        6       0       5   4   1   
        7       0       4   4   2   
        8       0       1   6   3   
        9       0       0   5   5   
        sum		        42	29	24	95
	    ratio	       13.2 9.1 7.5	 common chances is low by assuming most people cant reach level 10
        */
        if (TowerLevel <= 20 ) { //level1 stage 1
            _TowerPet.species = 5;
            _TowerPet.power.hitpoints = 15000+TowerLevel*700;
            _TowerPet.power.strength = uint16(10+((TowerLevel*75)%50));
            _TowerPet.power.agility = uint16(10+((TowerLevel*88)%50));
            _TowerPet.power.intellegence = uint16(10+((TowerLevel*33)%50));
            _chances = [1,8,1,0];
            _nextTowerLevel = uint8(_RandNumb(_deRand,60,41)); //intentionally skip
        } else if (TowerLevel <= 40 ) { //level2 stage 1
            _TowerPet.species = 7;
            _TowerPet.power.hitpoints = 18000+((TowerLevel*900)%18000);
            _TowerPet.power.strength = uint16(30+((TowerLevel*75)%50));
            _TowerPet.power.agility = uint16(30+((TowerLevel*88)%50));
            _TowerPet.power.intellegence = uint16(30+((TowerLevel*33)%50));
            _chances = [1,7,2,0];
            _nextTowerLevel = uint8(_RandNumb(_deRand,80,41));
        } else if (TowerLevel <= 60 ) { //level3 stage 2
            _TowerPet.species = 10;
            _TowerPet.power.hitpoints = 35000+((TowerLevel*1900)%30000);
            _TowerPet.power.strength = uint16(70+((TowerLevel*75)%70));
            _TowerPet.power.agility = uint16(70+((TowerLevel*88)%70));
            _TowerPet.power.intellegence = uint16(70+((TowerLevel*33)%70));
            _TowerPet.skill = [10,0,0]; 
            _chances = [1,6,2,1];
            _nextTowerLevel = uint8(_RandNumb(_deRand,100,81)); //skip
        } else if (TowerLevel <= 80 ) { //level4 stage 2
            _TowerPet.species = 16;
            _TowerPet.power.hitpoints = 70000+((TowerLevel*1900)%70000);
            _TowerPet.power.strength = uint16(100+((TowerLevel*75)%100));
            _TowerPet.power.agility = uint16(100+((TowerLevel*88)%100));
            _TowerPet.power.intellegence = uint16(120+((TowerLevel*33)%120));
            _TowerPet.skill = [16,0,0]; 
            _chances = [1,6,2,1];
            _nextTowerLevel = uint8(_RandNumb(_deRand,120,81));
        } else if (TowerLevel <= 100 ) { //level5 stage 2
            _TowerPet.species = 17;
            _TowerPet.power.hitpoints = 100000+((TowerLevel*1900)%70000);
            _TowerPet.power.strength = uint16(150+((TowerLevel*75)%100));
            _TowerPet.power.agility = uint16(150+((TowerLevel*88)%100));
            _TowerPet.power.intellegence = uint16(180+((TowerLevel*33)%120));
            _TowerPet.skill = [17,0,0]; 
            _chances = [1,5,3,1];
            _nextTowerLevel = uint8(_RandNumb(_deRand,140,121));
        } else if (TowerLevel <= 120 ) { //level6 stage 3
            _TowerPet.species = 23;
            _TowerPet.power.hitpoints = 250000+((TowerLevel*1900)%130000);
            _TowerPet.power.strength = uint16(220+((TowerLevel*75)%100));
            _TowerPet.power.agility = uint16(220+((TowerLevel*88)%100));
            _TowerPet.power.intellegence = uint16(350+((TowerLevel*33)%120));
            _TowerPet.skill = [10,23,0]; 
            _chances = [0,5,4,1];
            _nextTowerLevel = uint8(_RandNumb(_deRand,160,121));
        } else if (TowerLevel <= 140 ) { //level7 stage 3
            _TowerPet.species = 30;
            _TowerPet.power.hitpoints = 350000+((TowerLevel*1900)%170000);
            _TowerPet.power.strength = uint16(350+((TowerLevel*75)%100));
            _TowerPet.power.agility = uint16(350+((TowerLevel*88)%100));
            _TowerPet.power.intellegence = uint16(550+((TowerLevel*33)%120));
            _TowerPet.skill = [16,30,0];
            _chances = [0,4,4,2]; 
            _nextTowerLevel = uint8(_RandNumb(_deRand,180,161));
        } else if (TowerLevel <= 160 ) { //level8 stage 3
            _TowerPet.species = 37;
            _TowerPet.power.hitpoints = 450000+((TowerLevel*1900)%270000);
            _TowerPet.power.strength = uint16(450+((TowerLevel*75)%150));
            _TowerPet.power.agility = uint16(450+((TowerLevel*88)%150));
            _TowerPet.power.intellegence = uint16(660+((TowerLevel*33)%120));
            _TowerPet.skill = [17,37,0]; 
            _chances = [0,1,6,3];
            _nextTowerLevel = uint8(_RandNumb(_deRand,200,161));
        } else if (TowerLevel <= 180 ) { //level9 stage 4
            _TowerPet.species = 44;
            _TowerPet.power.hitpoints = 600000+((TowerLevel*1900)%300000);
            _TowerPet.power.strength = uint16(600+((TowerLevel*75)%150));
            _TowerPet.power.agility = uint16(600+((TowerLevel*88)%150));
            _TowerPet.power.intellegence = uint16(730+((TowerLevel*33)%120));
            _TowerPet.skill = [10,23,44]; 
            _chances = [0,0,5,5];
            _nextTowerLevel = uint8(_RandNumb(_deRand,200,181));
        } else if (TowerLevel <= 200 ) { //level10 stage 4
            _TowerPet.species = 54;
            _TowerPet.power.hitpoints = 900000+((TowerLevel*1900)%100000);
            _TowerPet.power.strength = uint16(900+((TowerLevel*75)%100));
            _TowerPet.power.agility = uint16(900+((TowerLevel*88)%100));
            _TowerPet.power.intellegence = uint16(900+((TowerLevel*33)%100));
            _TowerPet.skill = [17,37,54]; 
            _chances = [0,0,0,10];
            _nextTowerLevel = uint8(_RandNumb(_deRand,20,1));
        }
    }

    function battlePet(uint _deRand, A.Pets memory _Pet1, A.Pets memory _Pet2) 
    //check owner at main, because simulation need permissionless
    external pure returns(bool Mon1Win, uint BattleRhythm, uint8 bit, uint64 OppoDamage) { 
        //---- The BattleRythm is 256 bits encoded 85 actions(3bits [1bit attacker, 2bits skill]), 
        // ---- so the battle ended after 85 turns or either one has 0 HP---------------- 
        //whoever has more HP left win, if same HP, Pet2 win. NO DRAW -----------//
        uint32 damage;
        uint32 effort;
        uint32 actionpoints1 = _Pet2.power.agility; //reverse, Pet2 slow, means Pet1 attack more times
        uint32 actionpoints2 = _Pet1.power.agility;
        uint8 weakness; //0 = nothing, 1 = more damage on Pet1, 2= more daamge on Pet2
                //0 = Red, 1=Yellow, 2=Green, 3=Blue, 4=Purple
        //Yellow==Purple==Red==Green==Blue
        //1.2x against
	    //Blue==Yellow==Green==Purple==Red
        if ( (_Pet1.family == 3 && _Pet2.family == 1) //Blue weaks against Yellow
           ||(_Pet1.family == 1 && _Pet2.family == 4) //Yellow weaks against Purple
           ||(_Pet1.family == 2 && _Pet2.family == 0) //Green weaks against Red
           ||(_Pet1.family == 4 && _Pet2.family == 2) //Purple weaks against Green
           ||(_Pet1.family == 0 && _Pet2.family == 3) //Red weaks against Blue
        ) 
        {weakness = 1;}
        //---
        if ( (_Pet2.family == 3 && _Pet1.family == 1) //Blue weaks against Yellow
           ||(_Pet2.family == 1 && _Pet1.family == 4) //Yellow weaks against Purple
           ||(_Pet2.family == 2 && _Pet1.family == 0) //Green weaks against Red
           ||(_Pet2.family == 4 && _Pet1.family == 2) //Purple weaks against Green
           ||(_Pet2.family == 0 && _Pet1.family == 3) //Red weaks against Blue
        ) 
        {weakness = 2;}
        // because who has less actionpoints move next
        //while<= 253 bit 1round 3 bit 15 rounds, means 45 bit
        while (bit<=253 && _Pet1.power.hitpoints > 0 && _Pet2.power.hitpoints > 0 ){
            if (actionpoints1 <= actionpoints2) { //Pet1 move
                bit++; //bit ++ first, means set '0'
                _deRand = (_deRand>>3)+(_deRand>>1);
                (BattleRhythm,effort,damage)=_chooseSkill(_deRand,_Pet1,BattleRhythm,bit);
                bit=bit+2; //2bits has set in the function above for skill.
                actionpoints1 = actionpoints1 + effort +  _Pet2.power.agility; // purposely reverse Pet2 agi to action 1
                if (weakness == 2) {damage = damage*2;}
                _Pet2.power.hitpoints = sub32b(_Pet2.power.hitpoints,damage);
                OppoDamage += damage;
            } else { //Pet2 move
                BattleRhythm = BattleRhythm + 2**bit; //encode who attack, 1 = Pet2 attack
                bit++; //bit++ before set, means set '1'
                _deRand = (_deRand>>3)+(_deRand>>1);
                (BattleRhythm,effort,damage)=_chooseSkill(_deRand,_Pet2,BattleRhythm,bit);
                bit=bit+2; //2bits has set in the function above.
                actionpoints2 = actionpoints2 + effort +  _Pet1.power.agility; // purposely reverse Pet1 agi to action 2
                if (weakness == 1) {damage = damage*2;}
                _Pet1.power.hitpoints = sub32b(_Pet1.power.hitpoints,damage);
            }
        }
        if (_Pet1.power.hitpoints >= _Pet2.power.hitpoints) {Mon1Win = true;} else {Mon1Win = false;}
        
    }
    function _chooseSkill(uint _deRand, A.Pets memory _Pet, uint _BattleRhythm, uint8 _bit)
    private pure returns( uint BattleRhythm, uint32 effort, uint32 damage) {
        uint8 skill;
        BattleRhythm = _BattleRhythm;
        if (_RandNumb(_deRand,1300,1) <= 301+uint16(_Pet.power.intellegence)) { //use skills based 23% chances
            skill = uint8(_RandNumb((_deRand>>3)+(_deRand>>1),2,0)); //translate to skill array 0 1 2
            //skill == 0 means no need to set anything on skill (00)
            if (skill == 1) {BattleRhythm = BattleRhythm + 2**_bit;} //binary 00 (01) 10, set LSB
            _bit++;
            if (skill == 2) {BattleRhythm = BattleRhythm + 2**_bit;} //binary 00 01 (10), set MSB
            //no need _bit++ as _bit won't return
            (damage,effort) = _SkillsState(_Pet.power,_Pet.attribute, _Pet.skill[skill]);
        } else {//normal attack, also encoded as skill array (11), Skill[3] always normal attack
            BattleRhythm = BattleRhythm + 2**_bit;
            _bit++;
            BattleRhythm = BattleRhythm + 2**_bit;
            damage = _Pet.power.strength;
            damage = damage * 50;
            effort = 100;
        } 
        
    }
    function _SkillsState(A.powers memory _powers, A.attributes memory _attributes, uint8 SkillNumber)
    private pure returns(uint32 damage, uint32 effort) {
        // you won't get a skill before Stage 2
        uint64 HP = _powers.hitpoints;
        uint32 STR = _powers.strength;
        uint32 AGI = _powers.agility;
        uint32 INT = _powers.intellegence;
        uint32 HAPPINESS = _attributes.happiness;
        uint32 DISCIPLINE = _attributes.discipline;
        if (SkillNumber == 0) {damage=STR*50; effort = 100;}
        else if (SkillNumber == 10) {damage= 50*STR + 35*AGI ; effort = 160;}   ///------- use this
        else if (SkillNumber == 11) {damage= 85*STR + 15*INT ; effort = 155;}
        else if (SkillNumber == 12) {damage= 115*STR ; effort = 200;}
        else if (SkillNumber == 13) {damage= 30*STR + 30*AGI + 30*INT ; effort = 150;}
        else if (SkillNumber == 14) {damage= 105*STR ; effort = 190;}
        else if (SkillNumber == 15) {damage= 40*STR + 63*AGI ; effort = 160;}
        else if (SkillNumber == 16) {damage= 40*STR + 60*AGI ; effort = 170;}   ///------- use this
        else if (SkillNumber == 17) {damage= 80*STR + 35*INT ; effort = 195;}   ///------- use this
        else if (SkillNumber == 18) {damage= 90*STR + 40*INT ; effort = 220;}
        else if (SkillNumber == 19) {damage= 50*STR + 100*INT ; effort = 230;}
        else if (SkillNumber == 20) {damage= 150*STR ; effort = 230;}
        else if (SkillNumber == 21) {damage= 50*STR + 100*AGI ; effort = 230;}
        else if (SkillNumber == 22) {damage= 50*STR + 50*AGI + 50*INT ; effort = 230;}
        else if (SkillNumber == 23) {damage= 75*STR + 125*AGI ; effort = 265;}   ///------- use this
        else if (SkillNumber == 24) {damage= 135*STR + 75*AGI ; effort = 270;}
        else if (SkillNumber == 25) {damage= 200*AGI ; effort = 266;}
        else if (SkillNumber == 26) {damage= uint32((14*HP)/100) + 125*STR ; effort = 287;}
        else if (SkillNumber == 27) {damage= 90*STR + 90*AGI + 90*INT ; effort = 330;}
        else if (SkillNumber == 28) {damage= 225*STR ; effort = 290;}
        else if (SkillNumber == 29) {damage= 50*STR + 125*AGI ; effort = 258;}
        else if (SkillNumber == 30) {damage= 90*STR + 110*AGI ; effort = 277;}   ///------- use this
        else if (SkillNumber == 31) {damage= 150*STR + 50*AGI ; effort = 302;}
        else if (SkillNumber == 32) {damage= 165*STR + 175*DISCIPLINE ; effort = 298;}
        else if (SkillNumber == 33) {damage= 185*INT ; effort = 244;}
        else if (SkillNumber == 34) {damage= 55*STR + 140*INT ; effort = 280;}
        else if (SkillNumber == 35) {damage= 250*STR ; effort = 295;}
        else if (SkillNumber == 36) {damage= 210*STR ; effort = 300;}
        else if (SkillNumber == 37) {damage= uint32((15*HP)/100) + 125*STR ; effort = 310;}   ///------- use this
        else if (SkillNumber == 38) {damage= 125*STR + 40*AGI + 40*INT ; effort = 275;}
        else if (SkillNumber == 39) {damage= 185*STR + 50*AGI ; effort = 295;}
        else if (SkillNumber == 40) {damage= 158*STR + 50*AGI + 25*INT ; effort = 287;}
        else if (SkillNumber == 41) {damage= 160*STR + 50*INT + 175*HAPPINESS ; effort = 320;}
        else if (SkillNumber == 42) {damage= 160*STR +50*INT + 175*DISCIPLINE ; effort = 315;}
        else if (SkillNumber == 43) {damage= 185*STR + 100*AGI ; effort = 380;}
        else if (SkillNumber == 44) {damage= 170*STR + 170*INT ; effort = 395;}   ///------- use this
        else if (SkillNumber == 45) {damage= uint32((25*HP)/100) + 100*STR ; effort = 376;}
        else if (SkillNumber == 46) {damage= 150*STR + 150*INT ; effort = 380;}
        else if (SkillNumber == 47) {damage= 325*STR ; effort = 400;}
        else if (SkillNumber == 48) {damage= 150*STR + 125*AGI + 50*INT ; effort = 375;}
        else if (SkillNumber == 49) {damage= 125*STR + 125*AGI + 125*INT ; effort = 450;}
        else if (SkillNumber == 50) {damage= 175*AGI + 100*INT + 200*HAPPINESS ; effort = 380;}
        else if (SkillNumber == 51) {damage= 75*STR + 200*INT + 250*DISCIPLINE ; effort = 385;}
        else if (SkillNumber == 52) {damage= 150*STR + 125*AGI + 175*HAPPINESS ; effort = 370;}
        else if (SkillNumber == 53) {damage= 175*STR + 700*DISCIPLINE ; effort = 395;}
        else if (SkillNumber == 54) {damage= 200*STR + 150*INT ; effort = 450;}   ///------- use this
        else if (SkillNumber == 55) {damage= 115*STR + 115*AGI + 115*INT ; effort = 400;}
        else if (SkillNumber == 56) {damage= 150*STR + 150*INT ; effort = 375;}
        else if (SkillNumber == 57) {damage= 125*STR + 100*STR + 100*INT ; effort = 360;}   ///------- use this
        else if (SkillNumber == 58) {damage= 60*STR + 75*INT + 750*HAPPINESS ; effort = 380;}
        else if (SkillNumber == 59) {damage= 345*INT ; effort = 400;}
        else if (SkillNumber == 60) {damage= 225*STR + 85*AGI ; effort = 360;}
        else if (SkillNumber == 61) {damage= 160*STR + 160*INT ; effort = 380;}
        else if (SkillNumber == 62) {damage= 125*STR + 200*INT ; effort = 385;}
        else if (SkillNumber == 63) {damage= 125*STR + 125*AGI + 125*INT ; effort = 400;}
    }

    function battlewinlosereward(A.Pets memory _Pet, bool _win, uint8 _rank) external view 
    returns (A.Pets memory Pet){
        Pet = _Pet;
        uint32 _exp;
        A.powers memory _pwrstemp;
        uint8 _happy;
        uint8 _discipline;
        uint32 _weight;
        if ( _rank >= 4 ) { //means not fight training
            if (_win == true) { // if won
            
                _exp = 820000;
                _pwrstemp.hitpoints =15000;
                _pwrstemp.strength =15;
                _pwrstemp.agility =15;
                _pwrstemp.intellegence =15;
                Pet.attribute.happiness = add8b(Pet.attribute.happiness,10);
                _discipline =5;
                _weight =3815;
                
            } else { //lose...
                _exp = 450000;
                _pwrstemp.hitpoints =6000;
                _pwrstemp.strength =6;
                _pwrstemp.agility =6;
                _pwrstemp.intellegence =6;
                Pet.attribute.happiness = sub8b(Pet.attribute.happiness,10);
                _discipline =5;
                _weight =3815;
            }
            (_pwrstemp, _happy, _discipline) = traitAddStateBattle(2 minutes, Pet.trait,_pwrstemp, _happy, _discipline);
        
            Pet.exp = add32b(Pet.exp,_exp); 
            Pet.power.hitpoints = add32B999999L(Pet.power.hitpoints,_pwrstemp.hitpoints);
            Pet.power.strength = add16B999L(Pet.power.strength,_pwrstemp.strength);
            Pet.power.agility = add16B999L(Pet.power.agility,_pwrstemp.agility);
            Pet.power.intellegence = add16B999L(Pet.power.intellegence,_pwrstemp.intellegence);
            Pet.attribute.happiness = add8b(Pet.attribute.happiness,_happy);
            Pet.attribute.discipline = add8b(Pet.attribute.discipline,_discipline);
            Pet.attribute.weight = sub32b(Pet.attribute.weight,_weight);
        }
        Pet = EVO.checkEvolve(Pet);
    }

    function traitAddStateBattle(uint64 _tiredness, uint8[3] memory _traits, A.powers memory _pwrstemp, uint8 _happy, uint8 _discipline) 
    private pure returns(A.powers memory pwrstemp, uint8 happy, uint8 discipline){
        pwrstemp = _pwrstemp;
        happy = _happy;
        discipline = _discipline;
        uint16 _bonushr =  uint16(_tiredness/1 minutes);
        for (uint256 i; i < 3; i++) {
                //training trait 1 to 4
                if      (_traits[i] == 5) { pwrstemp.hitpoints = pwrstemp.hitpoints + 100; //Pride
                                            pwrstemp.strength= pwrstemp.strength + 2;
                                            pwrstemp.agility = pwrstemp.agility + 2;
                                            pwrstemp.intellegence = pwrstemp.intellegence + 2;
                                        } 
                else if (_traits[i] == 6) { pwrstemp.hitpoints = pwrstemp.hitpoints + 1000; //Resilient
                                            pwrstemp.strength= pwrstemp.strength + 1;
                                            pwrstemp.agility = pwrstemp.agility + 1;
                                            pwrstemp.intellegence = pwrstemp.intellegence + 1;
                                        }  
                else if (_traits[i] == 7) {happy = happy+(15*uint8(_bonushr))/10;} //Hardworking
                else if (_traits[i] == 8) {discipline = discipline+(15*uint8(_bonushr))/10;} //Serious
                
                else if (_traits[i] == 9) {pwrstemp.intellegence = pwrstemp.intellegence +_bonushr;} //Creative
                else if (_traits[i] == 10) {pwrstemp.strength = pwrstemp.strength +_bonushr;} //Ambitious
                else if (_traits[i] == 11) {pwrstemp.agility = pwrstemp.agility +_bonushr;} //Multitasking

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




