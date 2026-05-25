// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Rocolor} from "src/Rocolor.sol";
import {DeployRocolor} from "script/DeployRocolor.s.sol";
import {RocolorTestHelpers} from "./RocolorTestHelpers.sol";

contract RocolorTestNaming is Test, Rocolor, RocolorTestHelpers {
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

    // function getMappingValueStorageSlot(uint256 mappingKey, uint256 mappingVariableStorageSlot)
    //     public
    //     pure
    //     returns (bytes32 mappingValueStorageSlot)
    // {
    //     mappingValueStorageSlot = keccak256(abi.encode(mappingKey, mappingVariableStorageSlot));
    // }

    // function convertStorageStringToColorNameString(bytes32 storageString)
    //     public
    //     pure
    //     returns (string memory nameString)
    // {
    //     bytes memory storageStringBytes = abi.encode(storageString);
    //     uint256 sizeByte = uint8(storageStringBytes[31]);
    //     require(sizeByte % 2 == 0, "storage string too long");
    //     bytes memory nameStringBytes = new bytes(sizeByte / 2);
    //     for (uint256 i = 0; i < (sizeByte / 2); i++) {
    //         nameStringBytes[i] = storageStringBytes[i];
    //     }
    //     nameString = string(nameStringBytes);
    // }

    // function getColorNameFromStorage(uint256 _tokenId, uint256 mappingVariableStorageSlot)
    //     public
    //     view
    //     returns (string memory colorName)
    // {
    //     // get the storage slot of the colorName
    //     bytes32 mappingValueStorageSlot = getMappingValueStorageSlot(_tokenId, mappingVariableStorageSlot);

    //     // get the value in that storage slot
    //     bytes32 storageValue = vm.load(address(rocolor), mappingValueStorageSlot);

    //     // get the colorName from that storage slot's value
    //     colorName = convertStorageStringToColorNameString(storageValue);
    // }

    function testChangeColorName_HappyPath() public {
        //// Arrange
        // already done via setUp() and with constant strings
        //// Act
        vm.prank(HERO);
        rocolor.changeColorName(MURPH_LIGHT_HEX_TRIPLET, SUPER_BORING_COLOR_NAME);
        //// Assert
        string memory colorNameFromStorage =
            getColorNameFromStorage(address(rocolor), MURPH_LIGHT_TOKEN_ID, COLOR_NAMES_MAPPING_BASE_SLOT);
        assertEq(colorNameFromStorage, SUPER_BORING_COLOR_NAME);
    }

    function testChangeColorName_NameLength() public {
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
        colorNameFromStorage =
            getColorNameFromStorage(address(rocolor), MURPH_LIGHT_TOKEN_ID, COLOR_NAMES_MAPPING_BASE_SLOT);
        assertEq(colorNameFromStorage, "abcdefghijabcdefghijabcdefghij1");

        // case: 30 passes
        vm.prank(HERO);
        rocolor.changeColorName(MURPH_LIGHT_HEX_TRIPLET, "abcdefghijabcdefghijabcdefghij");
        colorNameFromStorage =
            getColorNameFromStorage(address(rocolor), MURPH_LIGHT_TOKEN_ID, COLOR_NAMES_MAPPING_BASE_SLOT);
        assertEq(colorNameFromStorage, "abcdefghijabcdefghijabcdefghij");

        // case: 0 passes
        vm.prank(HERO);
        rocolor.changeColorName(MURPH_LIGHT_HEX_TRIPLET, "");
        colorNameFromStorage =
            getColorNameFromStorage(address(rocolor), MURPH_LIGHT_TOKEN_ID, COLOR_NAMES_MAPPING_BASE_SLOT);
        assertEq(colorNameFromStorage, "");

        // case: 1 passes
        vm.prank(HERO);
        rocolor.changeColorName(MURPH_LIGHT_HEX_TRIPLET, "a");
        colorNameFromStorage =
            getColorNameFromStorage(address(rocolor), MURPH_LIGHT_TOKEN_ID, COLOR_NAMES_MAPPING_BASE_SLOT);
        assertEq(colorNameFromStorage, "a");
    }

    function testChangeColorName_HexLength() public {
        string memory colorNameFromStorage;

        // case: length == 0
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorName("", SUPER_BORING_COLOR_NAME);

        // case: length == 1
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorName("C", SUPER_BORING_COLOR_NAME);

        // case: length == 5
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorName("C1B7A", SUPER_BORING_COLOR_NAME);

        // case: length == 6
        vm.prank(HERO);
        rocolor.changeColorName("C1B7A0", SUPER_BORING_COLOR_NAME);
        colorNameFromStorage =
            getColorNameFromStorage(address(rocolor), MURPH_LIGHT_TOKEN_ID, COLOR_NAMES_MAPPING_BASE_SLOT);
        assertEq(colorNameFromStorage, SUPER_BORING_COLOR_NAME);

        // case: length == 7
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorName("C1B7A02", SUPER_BORING_COLOR_NAME);
    }

    function testChangeColorName_HexNumeral() public {
        // case: bad char is first
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorName("G1B7A0", SUPER_BORING_COLOR_NAME);

        // case: bad char is middle
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorName("C1G7A0", SUPER_BORING_COLOR_NAME);

        // case: bad char is last
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorName("C1B7AG", SUPER_BORING_COLOR_NAME);

        // case: bad char is "*"
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorName("C1B7*0", SUPER_BORING_COLOR_NAME);

        // case: bad char is a space
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorName("C1B7 0", SUPER_BORING_COLOR_NAME);

        // case: bad char is ";"
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorName("C1B7;0", SUPER_BORING_COLOR_NAME);

        // case: bad chars are "\\"
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorName("C1\\7A0", SUPER_BORING_COLOR_NAME);
    }

    function testChangeColorName_Ownership() public {
        // not minted
        vm.expectPartialRevert(ERC721NonexistentToken.selector);
        vm.prank(HERO);
        rocolor.changeColorName("000000", SUPER_BORING_COLOR_NAME);

        // owned by somebody else
        vm.expectPartialRevert(ERC721IncorrectOwner.selector);
        vm.prank(VILLAIN);
        rocolor.changeColorName(MURPH_LIGHT_HEX_TRIPLET, SUPER_BORING_COLOR_NAME);
    }

    function testGetColorName_HappyPath() public {
        string memory colorNameFromFunction;
        string memory colorNameFromStorage;
        vm.prank(HERO);
        colorNameFromFunction = rocolor.getColorName(MURPH_LIGHT_HEX_TRIPLET);
        colorNameFromStorage =
            getColorNameFromStorage(address(rocolor), MURPH_LIGHT_TOKEN_ID, COLOR_NAMES_MAPPING_BASE_SLOT);
        assertEq(colorNameFromStorage, colorNameFromFunction);
    }

    function testGetColorName_HexLength() public {
        string memory colorNameFromFunction;
        string memory colorNameFromStorage;

        // case: length == 0
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        vm.prank(HERO);
        colorNameFromFunction = rocolor.getColorName("");

        // case: length == 1
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        vm.prank(HERO);
        colorNameFromFunction = rocolor.getColorName("C");

        // case: length == 5
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        vm.prank(HERO);
        colorNameFromFunction = rocolor.getColorName("C1B7A");

        // case: length == 6
        vm.prank(HERO);
        colorNameFromFunction = rocolor.getColorName("C1B7A0");
        colorNameFromStorage =
            getColorNameFromStorage(address(rocolor), MURPH_LIGHT_TOKEN_ID, COLOR_NAMES_MAPPING_BASE_SLOT);
        assertEq(colorNameFromStorage, colorNameFromFunction);

        // case: length == 7
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        vm.prank(HERO);
        colorNameFromFunction = rocolor.getColorName("C1B7A02");
    }

    function testGetColorName_HexNumeral() public {
        string memory colorNameFromFunction;

        // case: bad char is first
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        colorNameFromFunction = rocolor.getColorName("G1B7A0");

        // case: bad char is middle
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        colorNameFromFunction = rocolor.getColorName("C1G7A0");

        // case: bad char is last
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        colorNameFromFunction = rocolor.getColorName("C1B7AG");

        // case: bad char is "*""
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        colorNameFromFunction = rocolor.getColorName("C1B7*0");

        // case: bad char is a space
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        colorNameFromFunction = rocolor.getColorName("C1B7 0");

        // case: bad char is ";"
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        colorNameFromFunction = rocolor.getColorName("C1B7;0");

        // case: bad chars are "\\"
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        colorNameFromFunction = rocolor.getColorName("C1\\7A0");
    }

    function testGetColorName_Ownership() public {
        string memory colorNameFromFunction;
        string memory colorNameFromStorage;

        // not minted
        vm.prank(HERO);
        colorNameFromFunction = rocolor.getColorName("000000");
        colorNameFromStorage = getColorNameFromStorage(address(rocolor), 0, COLOR_NAMES_MAPPING_BASE_SLOT);
        assertEq(colorNameFromStorage, colorNameFromFunction);

        // owned by somebody else
        vm.prank(VILLAIN);
        colorNameFromFunction = rocolor.getColorName(MURPH_LIGHT_HEX_TRIPLET);
        colorNameFromStorage =
            getColorNameFromStorage(address(rocolor), MURPH_LIGHT_TOKEN_ID, COLOR_NAMES_MAPPING_BASE_SLOT);
        assertEq(colorNameFromStorage, colorNameFromFunction);
    }
}

// notes:
// console.log("FFFFFF is:", decimal);
// {Arrange, Act, Assert}

// backlog:
// TODO (maybe?) reverts if bad calc'd tokenId: size ... fuzz this and assert tokenId size limit?

