// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Rocolor} from "src/Rocolor.sol";
import {DeployRocolor} from "script/DeployRocolor.s.sol";
import {StorageSlot} from "@openzeppelin/contracts/utils/StorageSlot.sol";

contract RocolorTestConverting is Test, Rocolor {
    Rocolor rocolor;
    DeployRocolor deployer;
    string hexTriplet;
    uint256 tokenId;
    address HERO = makeAddr("hero");
    address VILLAIN = makeAddr("villain");
    uint256 constant MURPH_LIGHT_TOKEN_ID = 12695456;
    string constant MURPH_LIGHT_HEX_TRIPLET = "C1B7A0";
    string constant MURPH_LIGHT_COLOR_NAME = "MurphLight";
    string constant SUPER_BORING_COLOR_NAME = "Super Boring";
    uint256 constant WHITE_TOKEN_ID = 16777215;
    uint256 constant BLACK_TOKEN_ID = 0;
    uint256 constant OWNERS_MAPPING_BASE_SLOT = 2;
    uint256 constant COLOR_NAMES_MAPPING_BASE_SLOT = 7;

    function setUp() public {
        deployer = new DeployRocolor();
        rocolor = deployer.run();
        vm.deal(HERO, 10 ether);
        vm.prank(HERO);
        rocolor.mintColor{value: 1 ether}(MURPH_LIGHT_HEX_TRIPLET, MURPH_LIGHT_COLOR_NAME);
    }

    function getMappingSlot(uint256 _key, uint256 _baseSlot) public pure returns (bytes32) {
        bytes32 mappingSlot = keccak256(abi.encode(_key, _baseSlot));
        string memory printableMappingSlot = vm.toString(mappingSlot);
        console.log("mappingSlot is:", printableMappingSlot);
        return mappingSlot;
    }

    function convertStorageStringToNameString(bytes32 storageString) public pure returns (string memory nameString) {
        bytes memory storageStringBytes = abi.encode(storageString);
        uint256 sizeByte = uint8(storageStringBytes[31]);
        require(sizeByte % 2 == 0, "storage string too long");
        bytes memory nameStringBytes = new bytes(sizeByte / 2);
        for (uint256 i = 0; i < (sizeByte / 2); i++) {
            nameStringBytes[i] = storageStringBytes[i];
        }
        nameString = string(nameStringBytes);
    }

    function testChangeColorName_HappyPath() public {
        //// Arrange
        // already done via setUp() and with constant strings
        //// Act
        vm.prank(HERO);
        rocolor.changeColorName(MURPH_LIGHT_HEX_TRIPLET, SUPER_BORING_COLOR_NAME);
        //// Assert
        // get the slot
        bytes32 mappingSlot = getMappingSlot(MURPH_LIGHT_TOKEN_ID, COLOR_NAMES_MAPPING_BASE_SLOT);
        // get the value
        bytes32 mappingSlotValue = vm.load(address(rocolor), mappingSlot);
        // get the name
        string memory nameString = convertStorageStringToNameString(mappingSlotValue);
        // compare value
        assertEq(nameString, SUPER_BORING_COLOR_NAME);
    }
}

// notes:
// console.log("FFFFFF is:", decimal);
// {Arrange, Act, Assert}

// backlog:
// This is naming... changeColorName(hexTriplet, newColorName), getColorName(hexTriplet)
// happy path changing, and emits an event
// reverts if bad hex: length
// reverts if bad hex: numeral
// reverts if bad calc'd tokenId: size
// reverts if bad name: size
// reverts if token is not owned
// reverts if token is owned by someone else
// happy path getting
// above cases (most) for getting
