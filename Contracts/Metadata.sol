// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "./myPet.sol";
import "./base64.sol";
library Meta {

    uint64 private constant FULL_STAMINA = 40 minutes; //core has record too
  
    function buildURIbased64(A.Pets memory _Pet, string memory _imageURI, string memory _imageExt,uint64 _timenow, uint _id) 
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
        _imagelinkfull = string(abi.encodePacked(_imageURI,_toString(_id),_imageExt));
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
                
 //           "\"}, {\"trait_type\": \"Life Time\",\"value\": \"",_getDayHrsMin(_lifetime),   //cut feature due to time line for hackathon
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
        if (_skill == 10) {skilltemp = "Acid Bullet"; }
        else if (_skill == 11) {skilltemp = "Force Palm"; }
        else if (_skill == 12) {skilltemp = "Rock Throw"; }
        else if (_skill == 13) {skilltemp = "Fur Sting"; }
        else if (_skill == 14) {skilltemp = "Fire Ball"; }
        else if (_skill == 15) {skilltemp = "Gust"; }
        else if (_skill == 16) {skilltemp = "Magic Dust"; }
        else if (_skill == 17) {skilltemp = "Light Beam"; }
        else if (_skill == 18) {skilltemp = "Metal Scale"; }
        else if (_skill == 19) {skilltemp = "Blade Energy"; }
        else if (_skill == 20) {skilltemp = "Fire Tornado"; }
        else if (_skill == 21) {skilltemp = "Shadowball"; }
        else if (_skill == 22) {skilltemp = "Leaf Blade"; }
        else if (_skill == 23) {skilltemp = "Force Blow"; }
        else if (_skill == 24) {skilltemp = "Wicked Slash"; }
        else if (_skill == 25) {skilltemp = "Discharge"; }
        else if (_skill == 26) {skilltemp = "Frost Blast"; }
        else if (_skill == 27) {skilltemp = "Buble Wrap"; }
        else if (_skill == 28) {skilltemp = "Spinning Slash"; }
        else if (_skill == 29) {skilltemp = "Echo scream"; }
        else if (_skill == 30) {skilltemp = "Thunder Strike"; }
        else if (_skill == 31) {skilltemp = "Petal Blade"; }
        else if (_skill == 32) {skilltemp = "Crunch"; }
        else if (_skill == 33) {skilltemp = "Surprise"; }
        else if (_skill == 34) {skilltemp = "Pressure Smash"; }
        else if (_skill == 35) {skilltemp = "Take Down"; }
        else if (_skill == 36) {skilltemp = "Sparkly Swirl"; }
        else if (_skill == 37) {skilltemp = "Energy Missle"; }
        else if (_skill == 38) {skilltemp = "Sing a Song"; }
        else if (_skill == 39) {skilltemp = "Spirit Slash"; }
        else if (_skill == 40) {skilltemp = "Aimshot"; }
        else if (_skill == 41) {skilltemp = "Rainbow Force"; }
        else if (_skill == 42) {skilltemp = "Dark Swipes"; }
        else if (_skill == 43) {skilltemp = "Beat Up"; }
        else if (_skill == 44) {skilltemp = "Solar Beam"; }
        else if (_skill == 45) {skilltemp = "Toxic Bite"; }
        else if (_skill == 46) {skilltemp = "Sonicboom"; }
        else if (_skill == 47) {skilltemp = "Ancient Power"; }
        else if (_skill == 48) {skilltemp = "Bee Missle"; }
        else if (_skill == 49) {skilltemp = "Disaster"; }
        else if (_skill == 50) {skilltemp = "Line Wind"; }
        else if (_skill == 51) {skilltemp = "Crystal Lance"; }
        else if (_skill == 52) {skilltemp = "Hydro Pressure"; }
        else if (_skill == 53) {skilltemp = "Searing Blade"; }
        else if (_skill == 54) {skilltemp = "Star Laser"; }
        else if (_skill == 55) {skilltemp = "Explosive Smoke"; }
        else if (_skill == 56) {skilltemp = "Air Strike"; }
        else if (_skill == 57) {skilltemp = "Grave Shadow"; }
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
        if        (_species==0) {
            name = "Biped Egg";
            description = "The egg that is capable of hatching into a two-legged creature with advanced intelligence would likely be an extraordinary and unique specimen. It may appear similar to a typical egg of its species, but with certain distinct characteristics that set it apart. It could be larger, with a thicker and more robust shell, or have a unique pattern or coloration that is not found in regular eggs. It may also have advanced mechanisms for ensuring the survival and development of the creature within, such as a self-sustaining environment or specialized nutrients. Overall, the egg would be a rare and valuable find, representing the potential for the emergence of a highly evolved and intelligent being.";
         } else if (_species==2) {
            name = "Volant Egg";
            description = "An egg that hatches into a tiny winged creature with exceptional speed would be a rare and unique specimen. The egg would likely be smaller in size than that of a typical creature of its species, with a delicate and fragile shell. It may have a specific pattern or coloration that sets it apart from other eggs. The egg may also have specialized internal structure that would support the developing creature's wing growth and aerodynamic capabilities. It may have advanced mechanisms for ensuring the survival and development of the creature within, such as specialized nutrients and protective features that promote wing and muscle growth that allows fast mobility. Overall, this egg would represent the potential for the emergence of a swift and agile being, making it a valuable and highly sought-after find, despite its small size.";
        } else if (_species==3) {
            name = "Mech Egg";
            description = "A special egg with a metal shell that hatches into a mechanical creature with a lively heart and emotions would be an extraordinary and unique specimen. The metal shell would likely be highly durable and able to withstand a lot of external stress, providing protection for the creature inside. The egg may have advanced features such as a power source and control systems for the creature inside, as well as specialized internal structure that would support the development of the creature's emotional and cognitive abilities. The egg may also have specialized protective features that allow the creature to withstand a lot of attack. The egg may also be larger and heavier than a typical egg of its species. The metal shell may also have a specific design and coloration that sets it apart from other eggs. Overall, this egg would represent the potential for the emergence of a highly advanced and unique being, making it a valuable and highly sought-after find.";
        } else if (_species==5) {
            name = "Bipee";
            description = "This is a two-legged creature that exudes a friendly and curious nature, always eager to learn and explore the world around it. Its intelligence is sharp, and it has a natural inclination towards observation, taking in every detail of its surroundings. Its social nature is undeniable, it thrives on connections and relationships with others and will go out of its way to make friends. But it is not just a pushover, when faced with a stronger enemy, it is not afraid to ask for help and uses its intelligence to strategize and make allies. Its empathetic nature and ability to form strong bonds make it a valuable asset in any group, its presence is a breath of fresh air and its company is cherished by all. Its friendly and curious nature makes it a likable creature with a contagious positive energy.";
        } else if (_species==7) {
            name = "Wingee";
            description = "This winged creature is a wild spirit, free-flying through the skies, soaring on the winds of freedom. Though its wings may not yet be strong enough to withstand the powerful gusts, it is not one to be held back. It is a creature of independence, fiercely defending its autonomy, and will not tolerate any attempts to limit its actions. It is a creature of the wild, untamed and unbridled, always seeking new horizons and adventures. When danger arises, it is not one to stand and fight, instead, it uses its agility and speed to evade and hide, using its wits to survive. It is a creature of stealth and cunning, always watching, always waiting for the right moment to strike. It is a creature of mystery, as elusive as the wind, and just as unpredictable. It is a creature of wild beauty, with wings that catch the sunlight and create a trail of sparks in its wake. It is a creature to be admired and respected, for it is the embodiment of freedom and wildness.";
        } else if (_species==8) {
            name = "Mechee";
            description = "This mechanical creature is a unique and advanced organism, characterized by its combination of mechanical and biological systems. It possesses a lively heart and soul similar to other organic creatures, thus it is classified as a mechanical type of creature. It boasts a hybrid brain, comprising both organic and synthetic components, that functions at a rate 10 times faster than typical organisms. This enables advanced cognitive abilities, such as exceptional proficiency in arithmetic and logic, making this creature an ideal candidate for complex problem-solving tasks. The creature's mechanical systems are highly advanced, with a specialized internal structure that promotes efficient movement and durability. Its outer shell serves as a protective shield, shielding the creature from external threats and environmental factors.";
        } else if (_species==10) {
            name = "Hebe";
            description = "Hebe is a serpentine creature, a slithering master of gastronomy. It glides through the Fantom world, always on the hunt for new and delicious delicacies. Its insatiable appetite is matched only by its culinary expertise. It has a keen sense of taste and smell, able to discern the subtlest of flavors and aromas. It knows how to use spices and herbs to enhance the natural flavors of its food and create dishes that are truly mouth-watering. Wiggle is not just a creature of hunger, but also a creature of art. It's a chef of the highest order, able to whip up a storm in the kitchen and create culinary masterpieces. It's kitchen is its playground, where it experiments with new ingredients and techniques, always pushing the boundaries of what is possible. But Hebe is not just a chef, it's also a connoisseur. It savors each bite, relishing in the flavors and textures of the food.";
        } else if (_species==16) {
            name = "Wingoid";
            description = "Wingoid is a fantastical creature that is known for its love of rock music. It's said that when the Wingoid sings, it is able to flash light from its eyes and create a rainbow that dances in the sky. This unique ability makes its performances truly spectacular and mesmerizing. Wingoid is also known to have a strong connection with the weather. When it rains, it can harness the power of the storm to create a symphony of light and sound. It's said that the Wingoid's rainbow-colored eyes are able to reflect the raindrops, creating a dazzling display that is both beautiful and awe-inspiring. Furthermore, it's believed that the Wingoid has a special relationship with thunderstorms. During such weather, its singing intensifies and it's able to create thunderbolts with its voice, adding even more spectacle to its rock music performance. It's said that the Wingoid's songs can be heard even from great distances, drawing in crowds of enchanted listeners.";
        } else if (_species==17) {
            name = "IO-der";
            description = "IO-der is a mechanical being, created to work tirelessly. It is a creature of gears, wires and circuits, that never stops moving and never needs to rest. Its purpose is to tirelessly toil, completing tasks with precision and efficiency. It also has the ability to adapt and improve, so it can keep up with the ever-changing demands of its tasks. With its unyielding work ethic and magical enhancements, the IO-der is a force to be reckoned with, capable of completing tasks that would overwhelm even the strongest of mortals. But despite its mechanical nature, the IO-der is also said to possess a certain enigmatic quality, as if it has its own consciousness. Some say it's a creature that is not only tireless but also sentient, with a will of its own. Some even say that the IO-der has its own agenda, working towards some unknown purpose, but no one truly knows what the true nature of the IO-der is.";
        } else if (_species==23) {
            name = "Steelhead";
            description = "Steelhead is a creature of legend, feared by many and revered by few. Its body is that of a serpent, sleek and sinuous, but its head is forged from the finest steel, glinting in the moonlight as it patrols the outskirts of the town. It is said that this creature has a special ability to sense temperature, and can accurately gauge the warmth of its surroundings with a single glance. Despite its fearsome appearance, the Steelhead is a peaceful creature, and it is said that those who encounter it will feel a chill pass through their body, as if the Steelhead is imparting a warning to stay away. But for those brave enough to approach, they may find themselves in the presence of a creature of great power and wisdom.";
        } else if (_species==30) {
            name = "Birdori";
            description = "Birdori is a majestic creature that inhabits the skies, known for its love of flying during the rain. It has the ability to absorb the energy from thunderstorms by charging itself, making it a formidable creature in the air. Its waterproof feature makes it an ideal creature to fly during the storm, it can fly and absorb the energy without getting damaged. The Birdori is also known for its powerful and distinctive call, which it uses to communicate with other members of its species over long distances. It has a very high volume of sound when shouting, especially during a rainy day, making it one of the loudest creatures in the world. Its roar can be heard from miles away, which is why people often use their help to do long-distance communication. Its presence in the sky is a reminder of the power and beauty of nature. It's a creature that is hard not to appreciate.";
        } else if (_species==37) {
            name = "Ointank";
            description = "This creature is a skilled butcher who can cut through the toughest of meats with ease. it has the ability to magically preserve the meats it cuts, keeping them fresh for weeks on end. Its usually opens its shop in a dark and mysterious alleyway and is said to only be open at night. Some say that it has made a deal with dark forces to gain its abilities and that the meat it sells is not from this world. Despite this, many brave adventurers and gourmands seek out its shop, for the taste of its meats is said to be otherworldly and delicious.";
        } else if (_species==44) {
            name = "Solanake";
            description = "In the land of Fantom, a giant snake roamed with solar panels on its neck, converting sunlight into energy for the entire city. The snake's scales shimmered like gold in the sun, harnessing its power to bring light to the kingdom. People revered the creature as a gift from the gods, a symbol of prosperity and progress. It slithered through the land, leaving behind a trail of glowing energy that powered homes and machines. Its presence brought peace and progress to the land, and it will always be remembered as a true wonder of magic and technology.";
        } else if (_species==54) {
            name = "Mechindragon";
            description = "Mechindragon is truly a master of its kind, a being of immense power and intelligence. Unlike other mechanical creatures, it has no master, it has evolved to the point where it can make its own decisions and act independently. It commands all other mechanical creatures and leads them in battle, a true leader in the world of machines. It is feared and respected by all other mechanical creatures, who instinctively know that the Mechindragon is the most powerful of their kind. This giant mechanical drake stands tall above all other machines, with its sleek design and powerful laser cannon. It is a symbol of the future, a reminder of the incredible possibilities of technology. With its intelligence and its ability to act independently, it is truly the master of all machines, a ruler of the mechanical world.";
        } else if (_species==57) {
            name = "Feroth";
            description = "Feroth is a creature of ancient knowledge and power, a being who has spent centuries studying the secrets of the past. It is a creature of great wisdom and intelligence, with a deep understanding of the world and its history. It has the head of an eagle and the legs of an eagle, with a humanoid figure, making it an unusual creature to behold. It is able to fly using ancient technology, which is a mystery to most. Feroth is also skilled in the art of preserving corpses, it is able to keep the remains of the deceased intact for centuries, using methods that are long forgotten. This ability has made it a valuable ally to many who seek to honor their ancestors and keep their memory alive. Feroth is a creature of great integrity, it always seeks for justice, it is driven by a deep sense of fairness and morality. It is a being that will not rest until it sees wrongs righted and the innocent protected. It is a creature that is respected and admired by all who know it.";
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
