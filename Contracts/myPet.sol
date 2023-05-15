// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library A {

    // A struct to hold the attributes of a Pet
    struct attributes {
        uint8 happiness;   // The happiness level of the Pet (max 255)
        uint8 discipline;  // The discipline level of the Pet (max 255)
        uint16 id;         // The unique ID of the Pet, used to track the same token
        uint32 weight;     // The weight of the Pet in grams
        uint8 stage;       // The stage of the Pet's life cycle (0:Egg, 1:Youth, 2:Rookie, 3:Mature, 4:Perfect)
    }

    // A struct to hold the powers of a Pet
    struct powers {
        uint32 hitpoints;     // The ability of the Pet to take damage (max limit 9,999)
        uint16 strength;      // The strength of the Pet, affecting damage (max limit 999)
        uint16 agility;       // The agility of the Pet, affecting turns (max limit 999)
        uint16 intellegence;  // The intelligence of the Pet, affecting skill chances (max limit 999)
    }

    // A struct to hold the timings of a Pet
    struct timings {
        uint64 deadtime;       // The life cycle of the Pet
        uint64 endurance;      // The hunger/food level of the Pet
        uint64 frozentime;     // The time the Pet is frozen during an adventure
        uint64 stamina;        // The limit of activities the Pet can perform
        uint64 evolutiontime;  // The time when the Pet attempts to evolve
    }

    // A struct to hold the Pet's data
    struct Pets {
        uint8 species;       // The type of Pet
        uint256 gene;        // Each digit represents a type of Pet that has ever evolved
        attributes attribute;
        powers power;
        uint32 exp;          // The experience points gained from battles/evolutions, impacting evolution
        timings time;
        uint8[3] trait;      // The traits gained at every evolution
        uint8[3] skill;      // The skills gained at every evolution
        uint32 status;       // The status of the Pet
        uint16 family;       // The family of the Pet
        bool shinning;       // The shinning state of the Pet
    }
}
