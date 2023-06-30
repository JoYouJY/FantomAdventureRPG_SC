// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "./myPet.sol";
import "./base64.sol";
library Meta {

    uint64 private constant FULL_STAMINA = 40 minutes; //core has record too
  
    function buildURIbased64(A.Pets memory _Pet, string memory _imageURI, string memory _imageExt,uint64 _timenow,bool _namebyID) 
    external pure returns (string memory metadata) {
        string memory _name;
        string memory _imagelinkfull;
        string memory _description;
        string memory _attribute1;
        string memory _attribute2;
        string memory _attribute3;
        string memory _attribute4;
        (_name,_description) = _getNameDescription(_Pet.species);
        _attribute1 = _getAttribute1(_Pet,_timenow);
        _attribute2 = _getAttribute2(_Pet);
        _attribute3 = _getAttribute3(_Pet);
        _attribute4 = _getAttribute4(_Pet);
        _imagelinkfull = string(abi.encodePacked(_imageURI,_toString(_Pet.species),_imageExt));
        if (_namebyID == true) {
             metadata = string(abi.encodePacked("data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            "{\"name\": \"#",_toString(_Pet.attribute.id)," ",_name,
                            "\",\"description\": \"",_description,
                            "\",\"image\": \"",
                            _imagelinkfull,
                            _attribute1,_attribute2,_attribute3,_attribute4     
                        )
                    )
                )
            ));
        } else {
            metadata = string(abi.encodePacked("data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            "{\"name\": \"",_name,
                            "\",\"description\": \"",_description,
                            "\",\"image\": \"",
                            _imagelinkfull,
                            _attribute1,_attribute2,_attribute3,_attribute4     
                        )
                    )
                )
            ));
        }
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
    function _returnLevel(uint32 _exp) private pure returns (uint32 _level){
        _level= sqrt32b(_exp)/258 + 1; //min level 1 - max level 255
        
    }

    function _getAttribute1(A.Pets memory _Pet, uint64 _timenow) private pure returns (string memory attribute){
        
        string memory _stage;
        
        
        uint64 _endurance;
      
        uint64 _stamina;
        uint64 _diffTime;

       
        if (_Pet.attribute.stage == 0) {_stage = "Egg"; }
        else if (_Pet.attribute.stage == 1) {_stage = "Youth"; }
        else if (_Pet.attribute.stage == 2) {_stage = "Rookie"; }
        else if (_Pet.attribute.stage == 3) {_stage = "Matured"; }
            else {_stage = "Perfect"; }
        
        if (_Pet.status == 1) { /*frozen Pet time has to offset*/
            _diffTime = _timenow-_Pet.time.frozentime;
            _Pet.time.endurance = _Pet.time.endurance+(_diffTime);
            _Pet.time.evolutiontime = _Pet.time.evolutiontime+(_diffTime);
            _Pet.time.deadtime = _Pet.time.deadtime+(_diffTime);
            _Pet.time.stamina = _Pet.time.stamina+(_diffTime);
        }

        if (_Pet.time.endurance <= _timenow) {  _endurance=0; }
            else {_endurance = _Pet.time.endurance - _timenow; }
        
        if (_Pet.time.stamina >= _timenow) {  _stamina=0; }
            else {_stamina = _timenow - _Pet.time.stamina ; 
                    if (_stamina > FULL_STAMINA){_stamina = FULL_STAMINA;}
                    
                }
        attribute = string(abi.encodePacked(
            "\",   \"attributes\": [{\"trait_type\": \"'Stage\",\"value\": \"",bytes(_stage),
 //               \"trait_type\": \"Status\",\"value\": \"",bytes(_status),   //cut feature due to time line for hackathon
 //           "\"}, {\"trait_type\": \"Shinning\",\"value\": \"",bytes(_shinning),   //cut feature due to time line for hackathon
 //           "\"}, {
             "\"}, {\"trait_type\": \"'Species\",\"value\": \"",_toString(_Pet.species),   
            "\"}, {\"trait_type\": \"'Family\",\"value\": \"",_getFamily(_Pet.family),   //cut feature due to time line for hackathon
            "\"}, {\"trait_type\": \"_Endurance\",\"value\": \"",_getDayHrsMin(_endurance),
            "\"}, {\"trait_type\": \"_Stamina\",\"value\": \"",_getDayHrsMin(_stamina)
            
        ));
    } //divided into function2 as stack too deep.
     function _getAttribute2(A.Pets memory _Pet) private pure returns (string memory attribute){
        attribute = string(abi.encodePacked(
            "\"}, {\"trait_type\": \":::Level\",\"value\": \"",_toString(_returnLevel(_Pet.exp)),
            "\"}, {\"trait_type\": \"::HP\",\"value\": \"",_toString(_Pet.power.hitpoints),
            "\"}, {\"trait_type\": \"::STR\",\"value\": \"",_toString(_Pet.power.strength),
            "\"}, {\"trait_type\": \":AGI\",\"value\": \"",_toString(_Pet.power.agility),
            "\"}, {\"trait_type\": \":INT\",\"value\": \"",_toString(_Pet.power.intellegence),     
            "\"}, {\"trait_type\": \"Happiness\",\"value\": \"",_toString(_Pet.attribute.happiness)
            
        ));
    }//divided into function3 as stack too deep.
    function _getAttribute3(A.Pets memory _Pet) private pure returns (string memory attribute){      
        attribute = string(abi.encodePacked(       
            "\"}, {\"trait_type\": \"Discipline\",\"value\": \"",_toString(_Pet.attribute.discipline),
            "\"}, {\"trait_type\": \"Weight(g)\",\"value\": \"",_toString(_Pet.attribute.weight),          
            "\"}, {\"trait_type\": \"_Trait1\",\"value\": \"",_getTraits(_Pet.trait[0]),
            "\"}, {\"trait_type\": \"_Trait2\",\"value\": \"",_getTraits(_Pet.trait[1]),
            "\"}, {\"trait_type\": \"_Trait3\",\"value\": \"",_getTraits(_Pet.trait[2])
        ));
    }//divided into function4 as stack too deep.
    function _getAttribute4(A.Pets memory _Pet) private pure returns (string memory attribute){      
        attribute = string(abi.encodePacked(                 
            "\"}, {\"trait_type\": \"_Skill1\",\"value\": \"",_getSkills(_Pet.skill[0]),
            "\"}, {\"trait_type\": \"_Skill2\",\"value\": \"",_getSkills(_Pet.skill[1]),
            "\"}, {\"trait_type\": \"_Skill3\",\"value\": \"",_getSkills(_Pet.skill[2]),
//            "\"}, {\"trait_type\": \"Genetic\",\"value\": \"",_toString(_Pet.gene),  //cut feature due to time line for hackathon
            "\"}]}" 
        ));
    }

    function _getFamily(uint16 _family) private pure returns (bytes memory family){
        string memory familytemp;
        if (_family == 0) {familytemp = "Distinction"; }
        else if (_family == 1) {familytemp = "Celestial"; }
        else if (_family == 2) {familytemp = "Verdant"; }
        else if (_family == 3) {familytemp = "Fantasy"; }
        else if (_family == 4) {familytemp = "Abyss"; }
        family = bytes(familytemp);
    }
    function _getTraits(uint8 _trait) private pure returns (bytes memory trait){
        string memory traittemp;
        if (_trait == 0) {traittemp = "none"; }
        else if (_trait == 1) {traittemp = "Tough"; }
        else if (_trait == 2) {traittemp = "Brawler"; }
        else if (_trait == 3) {traittemp = "Nimble"; }
        else if (_trait == 4) {traittemp = "Smart"; }
        else if (_trait == 5) {traittemp = "Pride"; }
        else if (_trait == 6) {traittemp = "Resilient"; }
        else if (_trait == 7) {traittemp = "Hardworking"; }
        else if (_trait == 8) {traittemp = "Serious"; }
        else if (_trait == 9) {traittemp = "Creative"; }
        else if (_trait == 10) {traittemp = "Ambitious"; }
        else if (_trait == 11) {traittemp = "Multitasking"; }
        else if (_trait == 12) {traittemp = "Lonely"; }
        else if (_trait == 13) {traittemp = "Bashful"; }
        else if (_trait == 14) {traittemp = "Adamant"; }
        else if (_trait == 15) {traittemp = "Naughty"; }
        else if (_trait == 16) {traittemp = "Brave"; }
        else if (_trait == 17) {traittemp = "Timid"; }
        else if (_trait == 18) {traittemp = "Hasty"; }
        else if (_trait == 19) {traittemp = "Jolly"; }
        else if (_trait == 20) {traittemp = "Naive"; }
        else if (_trait == 21) {traittemp = "Quirky"; }
        else if (_trait == 22) {traittemp = "Mild"; }
        else if (_trait == 23) {traittemp = "Quiet"; }
        else if (_trait == 24) {traittemp = "Rash"; }
        else if (_trait == 25) {traittemp = "Modest"; }
        else if (_trait == 26) {traittemp = "Docile"; }
        else if (_trait == 27) {traittemp = "Relaxed"; }
        else if (_trait == 28) {traittemp = "Bold"; }
        else if (_trait == 29) {traittemp = "Impish"; }
        else if (_trait == 30) {traittemp = "Lax"; }
        else if (_trait == 31) {traittemp = "Careful";}
        else {traittemp = "none";}
        trait = bytes(traittemp);
    }
    function _getSkills(uint8 _skill) private pure returns (bytes memory skill){
        string memory skilltemp;
        //skill start at Rookie
        if (_skill == 10) {skilltemp = "Air Wave - X"; }
        else if (_skill == 11) {skilltemp = "Force Palm"; }
        else if (_skill == 12) {skilltemp = "Rock Throw"; }
        else if (_skill == 13) {skilltemp = "Fur Sting"; }
        else if (_skill == 14) {skilltemp = "Fire Ball"; }
        else if (_skill == 15) {skilltemp = "Gust"; }
        else if (_skill == 16) {skilltemp = "Air Wave - Y"; }
        else if (_skill == 17) {skilltemp = "Air Wave - Z"; }
        else if (_skill == 18) {skilltemp = "Metal Scale"; }
        else if (_skill == 19) {skilltemp = "Blade Energy"; }
        else if (_skill == 20) {skilltemp = "Fire Tornado"; }
        else if (_skill == 21) {skilltemp = "Shadowball"; }
        else if (_skill == 22) {skilltemp = "Leaf Blade"; }
        else if (_skill == 23) {skilltemp = "Flame Thrower - X"; }
        else if (_skill == 24) {skilltemp = "Wicked Slash"; }
        else if (_skill == 25) {skilltemp = "Discharge"; }
        else if (_skill == 26) {skilltemp = "Frost Blast"; }
        else if (_skill == 27) {skilltemp = "Buble Wrap"; }
        else if (_skill == 28) {skilltemp = "Spinning Slash"; }
        else if (_skill == 29) {skilltemp = "Echo scream"; }
        else if (_skill == 30) {skilltemp = "Flame Thrower - Y"; }
        else if (_skill == 31) {skilltemp = "Petal Blade"; }
        else if (_skill == 32) {skilltemp = "Crunch"; }
        else if (_skill == 33) {skilltemp = "Surprise"; }
        else if (_skill == 34) {skilltemp = "Pressure Smash"; }
        else if (_skill == 35) {skilltemp = "Take Down"; }
        else if (_skill == 36) {skilltemp = "Sparkly Swirl"; }
        else if (_skill == 37) {skilltemp = "Flame Thrower - Z"; }
        else if (_skill == 38) {skilltemp = "Sing a Song"; }
        else if (_skill == 39) {skilltemp = "Spirit Slash"; }
        else if (_skill == 40) {skilltemp = "Aimshot"; }
        else if (_skill == 41) {skilltemp = "Rainbow Force"; }
        else if (_skill == 42) {skilltemp = "Dark Swipes"; }
        else if (_skill == 43) {skilltemp = "Beat Up"; }
        else if (_skill == 44) {skilltemp = "Mega Flare - X"; }
        else if (_skill == 45) {skilltemp = "Toxic Bite"; }
        else if (_skill == 46) {skilltemp = "Sonicboom"; }
        else if (_skill == 47) {skilltemp = "Ancient Power"; }
        else if (_skill == 48) {skilltemp = "Bee Missle"; }
        else if (_skill == 49) {skilltemp = "Disaster"; }
        else if (_skill == 50) {skilltemp = "Line Wind"; }
        else if (_skill == 51) {skilltemp = "Crystal Lance"; }
        else if (_skill == 52) {skilltemp = "Hydro Pressure"; }
        else if (_skill == 53) {skilltemp = "Searing Blade"; }
        else if (_skill == 54) {skilltemp = "Mega Flare - Z"; }
        else if (_skill == 55) {skilltemp = "Explosive Smoke"; }
        else if (_skill == 56) {skilltemp = "Air Strike"; }
        else if (_skill == 57) {skilltemp = "Mega Flare - Y"; }
        else if (_skill == 58) {skilltemp = "Shadow Cut"; }
        else if (_skill == 59) {skilltemp = "Starfall"; }
        else if (_skill == 60) {skilltemp = "Earth Shake"; }
        else if (_skill == 61) {skilltemp = "Psycodamage"; }
        else if (_skill == 62) {skilltemp = "Sunraze Slash"; }
        else if (_skill == 63) {skilltemp = "Giga Blast"; }
        else {skilltemp = "none";}
        skill = bytes(skilltemp);
    }

    function _getNameDescription(uint8 _species) private pure returns (string memory name, string memory description) {
        //---
        description = "Experience the transformative Pet NFT in Fantom Adventure RPG, an immersive on-chain game. Watch it evolve through gameplay. Refresh the metadata for the latest status since it will evolve and bring it to explore the captivating world of Fantom Adventure RPG.";
        if        (_species==0) {
            name = "Mystery Box - X";
         } else if (_species==2) {
            name = "Mystery Box - Y";
        } else if (_species==3) {
            name = "Mystery Box - Z";
        } else if (_species==5) {
            name = "Youpling - X";
        } else if (_species==7) {
            name = "Youpling - Y";
        } else if (_species==8) {
            name = "Youpling - Z";
        } else if (_species==10) {
            name = "Youphorn - X";
 
        } else if (_species==16) {
            name = "Youphorn - Y";
 
        } else if (_species==17) {
            name = "Youphorn - Z";
 
        } else if (_species==23) {
            name = "Yougon - X";
 
        } else if (_species==30) {
            name = "Yougon - Y";
 
        } else if (_species==37) {
            name = "Yougon - Z";
 
        } else if (_species==44) {
            name = "Youking - X";
 
        } else if (_species==54) {
            name = "Youking - Z";
 
        } else if (_species==57) {
            name = "Youking - Y";
 
        }
        //---  
    }

    function _getDayHrsMin(uint64 _time) private pure returns (string memory timeDHM) {
        uint64 _day;
        uint64 _hour;
        uint64 _minute;
        uint64 _temp;
        _temp = _time;
        _day = _temp / 86400; _temp = _temp - _day*86400;
        _hour = _temp / 3600; _temp = _temp - _hour*3600;
        _minute = _temp / 60;
        timeDHM = string(abi.encodePacked(_toString(_day),"d ",_toString(_hour),"h ",_toString(_minute),"m"));
    }
   
}
