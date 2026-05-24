// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Rocolor} from "src/Rocolor.sol";
import {DeployRocolor} from "script/DeployRocolor.s.sol";
// import {StorageSlot} from "@openzeppelin/contracts/utils/StorageSlot.sol";

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

    function getMappingValueStorageSlot(uint256 mappingKey, uint256 mappingVariableStorageSlot)
        public
        pure
        returns (bytes32 mappingValueStorageSlot)
    {
        mappingValueStorageSlot = keccak256(abi.encode(mappingKey, mappingVariableStorageSlot));
    }

    function convertStorageStringToColorNameString(bytes32 storageString)
        public
        pure
        returns (string memory nameString)
    {
        bytes memory storageStringBytes = abi.encode(storageString);
        uint256 sizeByte = uint8(storageStringBytes[31]);
        require(sizeByte % 2 == 0, "storage string too long");
        bytes memory nameStringBytes = new bytes(sizeByte / 2);
        for (uint256 i = 0; i < (sizeByte / 2); i++) {
            nameStringBytes[i] = storageStringBytes[i];
        }
        nameString = string(nameStringBytes);
    }

    function getColorNameFromStorage(uint256 _tokenId, uint256 mappingVariableStorageSlot)
        public
        view
        returns (string memory colorName)
    {
        // get the storage slot of the colorName
        bytes32 mappingValueStorageSlot = getMappingValueStorageSlot(_tokenId, mappingVariableStorageSlot);

        // get the value in that storage slot
        bytes32 storageValue = vm.load(address(rocolor), mappingValueStorageSlot);

        // get the colorName from that storage slot's value
        colorName = convertStorageStringToColorNameString(storageValue);
    }

    function testChangeColorName_HappyPath() public {
        //// Arrange
        // already done via setUp() and with constant strings
        //// Act
        vm.prank(HERO);
        rocolor.changeColorName(MURPH_LIGHT_HEX_TRIPLET, SUPER_BORING_COLOR_NAME);
        //// Assert
        string memory colorNameFromStorage =
            getColorNameFromStorage(MURPH_LIGHT_TOKEN_ID, COLOR_NAMES_MAPPING_BASE_SLOT);
        assertEq(colorNameFromStorage, SUPER_BORING_COLOR_NAME);
    }

    function testChangeColorName_Length() public {
        string memory colorNameFromStorage;

        // case: 32 fails
        vm.prank(HERO);
        vm.expectPartialRevert(ROColor__ColorNameTooBig.selector);
        rocolor.changeColorName(MURPH_LIGHT_HEX_TRIPLET, "abcdefghijabcdefghijabcdefghij12");

        // case: 33 fails
        vm.prank(HERO);
        vm.expectPartialRevert(ROColor__ColorNameTooBig.selector);
        rocolor.changeColorName(MURPH_LIGHT_HEX_TRIPLET, "abcdefghijabcdefghijabcdefghij123");

        // case: 31 passes
        vm.prank(HERO);
        rocolor.changeColorName(MURPH_LIGHT_HEX_TRIPLET, "abcdefghijabcdefghijabcdefghij1");
        colorNameFromStorage = getColorNameFromStorage(MURPH_LIGHT_TOKEN_ID, COLOR_NAMES_MAPPING_BASE_SLOT);
        assertEq(colorNameFromStorage, "abcdefghijabcdefghijabcdefghij1");

        // case: 30 passes
        vm.prank(HERO);
        rocolor.changeColorName(MURPH_LIGHT_HEX_TRIPLET, "abcdefghijabcdefghijabcdefghij");
        colorNameFromStorage = getColorNameFromStorage(MURPH_LIGHT_TOKEN_ID, COLOR_NAMES_MAPPING_BASE_SLOT);
        assertEq(colorNameFromStorage, "abcdefghijabcdefghijabcdefghij");

        // case: 0 passes
        vm.prank(HERO);
        rocolor.changeColorName(MURPH_LIGHT_HEX_TRIPLET, "");
        colorNameFromStorage = getColorNameFromStorage(MURPH_LIGHT_TOKEN_ID, COLOR_NAMES_MAPPING_BASE_SLOT);
        assertEq(colorNameFromStorage, "");

        // case: 1 passes
        vm.prank(HERO);
        rocolor.changeColorName(MURPH_LIGHT_HEX_TRIPLET, "a");
        colorNameFromStorage = getColorNameFromStorage(MURPH_LIGHT_TOKEN_ID, COLOR_NAMES_MAPPING_BASE_SLOT);
        assertEq(colorNameFromStorage, "a");
    }
}

// notes:
// console.log("FFFFFF is:", decimal);
// {Arrange, Act, Assert}

// backlog:
// This is naming... changeColorName(hexTriplet, newColorName), getColorName(hexTriplet)
// / happy path changing, and emits an event
// / reverts if bad name: size
// reverts if bad hex: length
// reverts if bad hex: numeral
// reverts if bad calc'd tokenId: size
// reverts if token is not owned
// reverts if token is owned by someone else
// happy path getting
// above cases (most) for getting
