// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library myPet {

    // A struct to hold the attributes of a myPet
    struct attributes {
        uint8 happiness;   // The happiness level of the myPet (max 255)
        uint8 discipline;  // The discipline level of the myPet (max 255)
        uint16 id;         // The unique ID of the myPet, used to track the same token
        uint32 weight;     // The weight of the myPet in grams
        uint8 stage;       // The stage of the myPet's life cycle (0:Egg, 1:Youth, 2:Rookie, 3:Mature, 4:Perfect)
    }

    // A struct to hold the powers of a myPet
    struct powers {
        uint32 hitpoints;     // The ability of the myPet to take damage (max limit 9,999)
        uint16 strength;      // The strength of the myPet, affecting damage (max limit 999)
        uint16 agility;       // The agility of the myPet, affecting turns (max limit 999)
        uint16 intellegence;  // The intelligence of the myPet, affecting skill chances (max limit 999)
    }

    // A struct to hold the timings of a myPet
    struct timings {
        uint64 deadtime;       // The life cycle of the myPet
        uint64 endurance;      // The hunger/food level of the myPet
        uint64 frozentime;     // The time the myPet is frozen during an adventure
        uint64 stamina;        // The limit of activities the myPet can perform
        uint64 evolutiontime;  // The time when the myPet attempts to evolve
    }

    // A struct to hold the myPet's data
    struct myPets {
        uint8 species;       // The type of myPet
        uint256 gene;        // Each digit represents a type of myPet that has ever evolved
        attributes attribute;
        powers power;
        uint32 exp;          // The experience points gained from battles/evolutions, impacting evolution
        timings time;
        uint8[3] trait;      // The traits gained at every evolution
        uint8[3] skill;      // The skills gained at every evolution
        uint32 status;       // The status of the myPet
        uint16 family;       // The family of the myPet
        bool shinning;       // The shinning state of the myPet
    }
}
