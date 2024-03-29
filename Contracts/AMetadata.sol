// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;
import "./myArtifact.sol";
library AMeta {
     

    function _getAEbyID(uint16 _id) private pure returns (Ar.ArtifactsEffects memory AE){
        if (_id == 0) {
            AE = Ar.ArtifactsEffects(_id, 0, 0, 0, 0, 0, 0);
        } else if (_id == 1) {
            AE = Ar.ArtifactsEffects(_id, 5, 5, 0, 0, 1, 1);
        } else if (_id == 2) {
            AE = Ar.ArtifactsEffects(_id, 5, 0, 5, 0, 1, 2);
        } else if (_id == 3) {
            AE = Ar.ArtifactsEffects(_id, 5, 0, 0, 5, 1, 3);
        } else if (_id == 4) {
            AE = Ar.ArtifactsEffects(_id, 0, 5, 5, 0, 1, 4);
        } else if (_id == 5) {
            AE = Ar.ArtifactsEffects(_id, 0, 5, 0, 5, 1, 5);
        } else if (_id == 6) {
            AE = Ar.ArtifactsEffects(_id, 0, 0, 10, 10, 2, 6);
        } else if (_id == 7) {
            AE = Ar.ArtifactsEffects(_id, 10, 10, 0, 0, 2, 7);
        } else if (_id == 8) {
            AE = Ar.ArtifactsEffects(_id, 0, 10, 10, 0, 2, 8);
        } else if (_id == 9) {
            AE = Ar.ArtifactsEffects(_id, 15, 0, 0, 15, 3, 9);
        } else if (_id == 10) {
            AE = Ar.ArtifactsEffects(_id, 0, 15, 15, 0, 3, 10);
        } else if (_id == 11) {
            AE = Ar.ArtifactsEffects(_id, 5, 0, 5, 0, 1, 1);
        } else if (_id == 12) {
            AE = Ar.ArtifactsEffects(_id, 0, 5, 0, 5, 1, 2);
        } else if (_id == 13) {
            AE = Ar.ArtifactsEffects(_id, 0, 5, 5, 0, 1, 3);
        } else if (_id == 14) {
            AE = Ar.ArtifactsEffects(_id, 0, 0, 5, 5, 1, 4);
        } else if (_id == 15) {
            AE = Ar.ArtifactsEffects(_id, 5, 5, 0, 0, 1, 5);
        } else if (_id == 16) {
            AE = Ar.ArtifactsEffects(_id, 10, 0, 10, 0, 2, 6); 
        } else if (_id == 17) {
            AE = Ar.ArtifactsEffects(_id, 0, 10, 0, 10, 2, 7);
        } else if (_id == 18) {
            AE = Ar.ArtifactsEffects(_id, 0, 10, 10, 0, 2, 8);
        } else if (_id == 19) {
            AE = Ar.ArtifactsEffects(_id, 15, 0, 0, 15, 3, 9);
        } else if (_id == 20) {
            AE = Ar.ArtifactsEffects(_id, 0, 15, 15, 0, 3, 10);
        } else if (_id == 21) {
            AE = Ar.ArtifactsEffects(_id, 5, 5, 0, 0, 1, 1);
        } else if (_id == 22) {
            AE = Ar.ArtifactsEffects(_id, 10, 0, 0, 0, 1, 2);
        } else if (_id == 23) {
            AE = Ar.ArtifactsEffects(_id, 0, 5, 5, 0, 1, 3);
        } else if (_id == 24) {
            AE = Ar.ArtifactsEffects(_id, 0, 0, 5, 5, 1, 4);
        } else if (_id == 25) {
            AE = Ar.ArtifactsEffects(_id, 0, 5, 0, 5, 1, 5);
        } else if (_id == 26) {
            AE = Ar.ArtifactsEffects(_id, 15, 0, 5, 0, 2, 6);
        } else if (_id == 27) {
            AE = Ar.ArtifactsEffects(_id, 0, 15, 5, 0, 2, 7);
        } else if (_id == 28) {
            AE = Ar.ArtifactsEffects(_id, 0, 0, 5, 15, 2, 8);
        } else if (_id == 29) {
            AE = Ar.ArtifactsEffects(_id, 0, 5, 15, 15, 3, 9);
        } else if (_id == 30) {
            AE = Ar.ArtifactsEffects(_id, 0, 15, 0, 15, 3, 10);
        }
    } 
    function _getAMbyID(uint16 _id) private pure returns (Ar.ArtifactsMetadata memory AM){
        string memory itemDescription = "The effectiveness of this item relies on the presence of duplicate artifacts in your inventory. Your current multiplier, referred to as n is determined by the number of duplicate artifacts you have equipped. To determine how many duplicates you need to reach a specific multiplier, you can utilize the formula 2 raised to the power of (n minus 1). For example, if you have 130 duplicates, you will attain a multiplier of 8. It's important to note that the maximum achievable multiplier is 9. The higher your multiplier, the more powerful the effects of the item become. To improve your gameplay performance, prioritize collecting additional duplicate artifacts to increase your multiplier.";
        if (_id == 0) {
            AM = Ar.ArtifactsMetadata("Gold", "A rare and precious resource, holds immense value in the realm. Its utility and purpose are yet to be discovered, waiting to unlock hidden secrets and potential within the world.", 0);
        } else if (_id == 1) {
            AM = Ar.ArtifactsMetadata("Ruby Ribbon", itemDescription, 1);
        } else if (_id == 2) {
            AM = Ar.ArtifactsMetadata("Lily Elegance", itemDescription, 1);
        } else if (_id == 3) {
            AM = Ar.ArtifactsMetadata("Faux Fecal", itemDescription, 1);
        } else if (_id == 4) {
            AM = Ar.ArtifactsMetadata("Pearl Petal", itemDescription, 1);
        } else if (_id == 5) {
            AM = Ar.ArtifactsMetadata("Breezeleaf", itemDescription, 1);
        } else if (_id == 6) {
            AM = Ar.ArtifactsMetadata("Whisker Wonderland", itemDescription, 1);
        } else if (_id == 7) {
            AM = Ar.ArtifactsMetadata("Featherflight", itemDescription, 1);
        } else if (_id == 8) {
            AM = Ar.ArtifactsMetadata("Purrfect Pinnacles", itemDescription, 1);
        } else if (_id == 9) {
            AM = Ar.ArtifactsMetadata("Twilight Flicker", itemDescription, 1);
        } else if (_id == 10) {
            AM = Ar.ArtifactsMetadata("Celestial Halo", itemDescription, 1);
        } else if (_id == 11) {
            AM = Ar.ArtifactsMetadata("Scholar - R", itemDescription, 2);
        } else if (_id == 12) {
            AM = Ar.ArtifactsMetadata("Scholar - Y", itemDescription, 2);
        } else if (_id == 13) {
            AM = Ar.ArtifactsMetadata("Scholar - B", itemDescription, 2);
        } else if (_id == 14) {
            AM = Ar.ArtifactsMetadata("Scholar - G", itemDescription, 2);
        } else if (_id == 15) {
            AM = Ar.ArtifactsMetadata("Scholar - C", itemDescription, 2);
        } else if (_id == 16) {
            AM = Ar.ArtifactsMetadata("Love Embrace - C", itemDescription, 2);
        } else if (_id == 17) {
            AM = Ar.ArtifactsMetadata("Love Embrace - P", itemDescription, 2);
        } else if (_id == 18) {
            AM = Ar.ArtifactsMetadata("Love Embrace - G", itemDescription, 2);
        } else if (_id == 19) {
            AM = Ar.ArtifactsMetadata("Celestial Harmony - X", itemDescription, 2);
        } else if (_id == 20) {
            AM = Ar.ArtifactsMetadata("Celestial Harmony - Y", itemDescription, 2);
        } else if (_id == 21) {
            AM = Ar.ArtifactsMetadata("Orbito Hex", itemDescription, 3);
        } else if (_id == 22) {
            AM = Ar.ArtifactsMetadata("Orbito Trix", itemDescription, 3);
        } else if (_id == 23) {
            AM = Ar.ArtifactsMetadata("Orbito Loid", itemDescription, 3);
        } else if (_id == 24) {
            AM = Ar.ArtifactsMetadata("Orbito Volt", itemDescription, 3);
        } else if (_id == 25) {
            AM = Ar.ArtifactsMetadata("Orbito Blaze", itemDescription, 3);
        } else if (_id == 26) {
            AM = Ar.ArtifactsMetadata("AeroBot Ion", itemDescription, 3);
        } else if (_id == 27) {
            AM = Ar.ArtifactsMetadata("AeroBot Byte", itemDescription, 3);
        } else if (_id == 28) {
            AM = Ar.ArtifactsMetadata("AeroBot Techno", itemDescription, 3);
        } else if (_id == 29) {
            AM = Ar.ArtifactsMetadata("Floatron Core", itemDescription, 3);
        } else if (_id == 30) {
            AM = Ar.ArtifactsMetadata("Floatron Pyro", itemDescription, 3);
        }

    } 
    function getAEbyID(uint16 _id) external pure returns (Ar.ArtifactsEffects memory AE){
        if (_id == 0) {
            AE = Ar.ArtifactsEffects(_id, 0, 0, 0, 0, 0, 0);
        } else if (_id == 1) {
            AE = Ar.ArtifactsEffects(_id, 5, 5, 0, 0, 1, 1);
        } else if (_id == 2) {
            AE = Ar.ArtifactsEffects(_id, 5, 0, 5, 0, 1, 2);
        } else if (_id == 3) {
            AE = Ar.ArtifactsEffects(_id, 5, 0, 0, 5, 1, 3);
        } else if (_id == 4) {
            AE = Ar.ArtifactsEffects(_id, 0, 5, 5, 0, 1, 4);
        } else if (_id == 5) {
            AE = Ar.ArtifactsEffects(_id, 0, 5, 0, 5, 1, 5);
        } else if (_id == 6) {
            AE = Ar.ArtifactsEffects(_id, 0, 0, 10, 10, 2, 6);
        } else if (_id == 7) {
            AE = Ar.ArtifactsEffects(_id, 10, 10, 0, 0, 2, 7);
        } else if (_id == 8) {
            AE = Ar.ArtifactsEffects(_id, 0, 10, 10, 0, 2, 8);
        } else if (_id == 9) {
            AE = Ar.ArtifactsEffects(_id, 15, 0, 0, 15, 3, 9);
        } else if (_id == 10) {
            AE = Ar.ArtifactsEffects(_id, 0, 15, 15, 0, 3, 10);
        } else if (_id == 11) {
            AE = Ar.ArtifactsEffects(_id, 5, 0, 5, 0, 1, 1);
        } else if (_id == 12) {
            AE = Ar.ArtifactsEffects(_id, 0, 5, 0, 5, 1, 2);
        } else if (_id == 13) {
            AE = Ar.ArtifactsEffects(_id, 0, 5, 5, 0, 1, 3);
        } else if (_id == 14) {
            AE = Ar.ArtifactsEffects(_id, 0, 0, 5, 5, 1, 4);
        } else if (_id == 15) {
            AE = Ar.ArtifactsEffects(_id, 5, 5, 0, 0, 1, 5);
        } else if (_id == 16) {
            AE = Ar.ArtifactsEffects(_id, 10, 0, 10, 0, 2, 6); 
        } else if (_id == 17) {
            AE = Ar.ArtifactsEffects(_id, 0, 10, 0, 10, 2, 7);
        } else if (_id == 18) {
            AE = Ar.ArtifactsEffects(_id, 0, 10, 10, 0, 2, 8);
        } else if (_id == 19) {
            AE = Ar.ArtifactsEffects(_id, 15, 0, 0, 15, 3, 9);
        } else if (_id == 20) {
            AE = Ar.ArtifactsEffects(_id, 0, 15, 15, 0, 3, 10);
        } else if (_id == 21) {
            AE = Ar.ArtifactsEffects(_id, 5, 5, 0, 0, 1, 1);
        } else if (_id == 22) {
            AE = Ar.ArtifactsEffects(_id, 10, 0, 0, 0, 1, 2);
        } else if (_id == 23) {
            AE = Ar.ArtifactsEffects(_id, 0, 5, 5, 0, 1, 3);
        } else if (_id == 24) {
            AE = Ar.ArtifactsEffects(_id, 0, 0, 5, 5, 1, 4);
        } else if (_id == 25) {
            AE = Ar.ArtifactsEffects(_id, 0, 5, 0, 5, 1, 5);
        } else if (_id == 26) {
            AE = Ar.ArtifactsEffects(_id, 15, 0, 5, 0, 2, 6);
        } else if (_id == 27) {
            AE = Ar.ArtifactsEffects(_id, 0, 15, 5, 0, 2, 7);
        } else if (_id == 28) {
            AE = Ar.ArtifactsEffects(_id, 0, 0, 5, 15, 2, 8);
        } else if (_id == 29) {
            AE = Ar.ArtifactsEffects(_id, 0, 5, 15, 15, 3, 9);
        } else if (_id == 30) {
            AE = Ar.ArtifactsEffects(_id, 0, 15, 0, 15, 3, 10);
        }
    } 
    function getAMbyID(uint16 _id) external pure returns (Ar.ArtifactsMetadata memory AM){
        string memory itemDescription = "The effectiveness of this item relies on the presence of duplicate artifacts in your inventory. Your current multiplier, referred to as n is determined by the number of duplicate artifacts you have equipped. To determine how many duplicates you need to reach a specific multiplier, you can utilize the formula 2 raised to the power of (n minus 1). For example, if you have 130 duplicates, you will attain a multiplier of 8. It's important to note that the maximum achievable multiplier is 9. The higher your multiplier, the more powerful the effects of the item become. To improve your gameplay performance, prioritize collecting additional duplicate artifacts to increase your multiplier.";
        if (_id == 0) {
            AM = Ar.ArtifactsMetadata("Gold", "A rare and precious resource, holds immense value in the realm. Its utility and purpose are yet to be discovered, waiting to unlock hidden secrets and potential within the world.", 0);
        } else if (_id == 1) {
            AM = Ar.ArtifactsMetadata("Ruby Ribbon", itemDescription, 1);
        } else if (_id == 2) {
            AM = Ar.ArtifactsMetadata("Lily Elegance", itemDescription, 1);
        } else if (_id == 3) {
            AM = Ar.ArtifactsMetadata("Faux Fecal", itemDescription, 1);
        } else if (_id == 4) {
            AM = Ar.ArtifactsMetadata("Pearl Petal", itemDescription, 1);
        } else if (_id == 5) {
            AM = Ar.ArtifactsMetadata("Breezeleaf", itemDescription, 1);
        } else if (_id == 6) {
            AM = Ar.ArtifactsMetadata("Whisker Wonderland", itemDescription, 1);
        } else if (_id == 7) {
            AM = Ar.ArtifactsMetadata("Featherflight", itemDescription, 1);
        } else if (_id == 8) {
            AM = Ar.ArtifactsMetadata("Purrfect Pinnacles", itemDescription, 1);
        } else if (_id == 9) {
            AM = Ar.ArtifactsMetadata("Twilight Flicker", itemDescription, 1);
        } else if (_id == 10) {
            AM = Ar.ArtifactsMetadata("Celestial Halo", itemDescription, 1);
        } else if (_id == 11) {
            AM = Ar.ArtifactsMetadata("Scholar - R", itemDescription, 2);
        } else if (_id == 12) {
            AM = Ar.ArtifactsMetadata("Scholar - Y", itemDescription, 2);
        } else if (_id == 13) {
            AM = Ar.ArtifactsMetadata("Scholar - B", itemDescription, 2);
        } else if (_id == 14) {
            AM = Ar.ArtifactsMetadata("Scholar - G", itemDescription, 2);
        } else if (_id == 15) {
            AM = Ar.ArtifactsMetadata("Scholar - C", itemDescription, 2);
        } else if (_id == 16) {
            AM = Ar.ArtifactsMetadata("Love Embrace - C", itemDescription, 2);
        } else if (_id == 17) {
            AM = Ar.ArtifactsMetadata("Love Embrace - P", itemDescription, 2);
        } else if (_id == 18) {
            AM = Ar.ArtifactsMetadata("Love Embrace - G", itemDescription, 2);
        } else if (_id == 19) {
            AM = Ar.ArtifactsMetadata("Celestial Harmony - X", itemDescription, 2);
        } else if (_id == 20) {
            AM = Ar.ArtifactsMetadata("Celestial Harmony - Y", itemDescription, 2);
        } else if (_id == 21) {
            AM = Ar.ArtifactsMetadata("Orbito Hex", itemDescription, 3);
        } else if (_id == 22) {
            AM = Ar.ArtifactsMetadata("Orbito Trix", itemDescription, 3);
        } else if (_id == 23) {
            AM = Ar.ArtifactsMetadata("Orbito Loid", itemDescription, 3);
        } else if (_id == 24) {
            AM = Ar.ArtifactsMetadata("Orbito Volt", itemDescription, 3);
        } else if (_id == 25) {
            AM = Ar.ArtifactsMetadata("Orbito Blaze", itemDescription, 3);
        } else if (_id == 26) {
            AM = Ar.ArtifactsMetadata("AeroBot Ion", itemDescription, 3);
        } else if (_id == 27) {
            AM = Ar.ArtifactsMetadata("AeroBot Byte", itemDescription, 3);
        } else if (_id == 28) {
            AM = Ar.ArtifactsMetadata("AeroBot Techno", itemDescription, 3);
        } else if (_id == 29) {
            AM = Ar.ArtifactsMetadata("Floatron Core", itemDescription, 3);
        } else if (_id == 30) {
            AM = Ar.ArtifactsMetadata("Floatron Pyro", itemDescription, 3);
        }
    } 
    function getSlotbyID(uint8 _id) external pure returns (uint8 slot){
        if (_id == 0) {
            slot = 0;
        } else if (_id >= 1 && _id <= 10) {
            slot = 1;
        } else if (_id >= 11 && _id <= 20) {
            slot = 2;
        } else if (_id >= 21 && _id <= 30) {
            slot = 3;
        }
    }
    function _getEquipedArtifactsEffects(uint8[3] memory id, uint8[3] memory multiplier) external pure returns (uint32[4] memory ABCD) {
        Ar.ArtifactsEffects memory AE1 = _getAEbyID(id[0]);
        Ar.ArtifactsEffects memory AE2 = _getAEbyID(id[1]);
        Ar.ArtifactsEffects memory AE3 = _getAEbyID(id[2]);

        ABCD[0] = AE1.A*multiplier[0]+ AE2.A*multiplier[1] + AE3.A*multiplier[2];
        ABCD[1] = AE1.B*multiplier[0]+ AE2.B*multiplier[1] + AE3.B*multiplier[2];
        ABCD[2] = AE1.C*multiplier[0]+ AE2.C*multiplier[1] + AE3.C*multiplier[2];
        ABCD[3] = AE1.D*multiplier[0]+ AE2.D*multiplier[1] + AE3.D*multiplier[2];

           
    }

    
}
