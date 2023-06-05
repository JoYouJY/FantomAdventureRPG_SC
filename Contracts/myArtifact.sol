// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Ar {
    struct ArtifactsEffects {
        uint16 id;         // The unique ID of the Pet, used to track the same token
        uint32 A;   // HP +
        uint32 B;  // STR +
        uint32 C;   // AGI +
        uint32 D;   // INT +
        uint8 R; // rarity 0 = gold, 1 = common, 2 = rare, 3 = mystical
        uint8 set; // if there is set artifact, this will indicate whether they are same set for extra effect
    }
    struct ArtifactsMetadata {
        string name;   // The name of the artifact
        string description;   // The unique ID of the Pet, used to track the same token
        uint8 slot; //this artifact is meant to wear for head/body/etc
    }
}
