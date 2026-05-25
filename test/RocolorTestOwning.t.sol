// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Rocolor} from "src/Rocolor.sol";
import {DeployRocolor} from "script/DeployRocolor.s.sol";
import {RocolorTestHelpers} from "./RocolorTestHelpers.sol";

contract RocolorTestOwning is Test, Rocolor, RocolorTestHelpers {
    Rocolor rocolor;
    DeployRocolor deployer;
    string hexTriplet;
    uint256 tokenId;
    address HERO = makeAddr("hero");
    address VILLAIN = makeAddr("villain");
    address FRIEND = makeAddr("friend");
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

    function testChangeColorOwner_HappyPath() public {
        //// Arrange
        // already done via setUp() and with constant strings
        //// Act
        vm.prank(HERO);
        vm.expectEmit();
        emit Transfer(HERO, FRIEND, MURPH_LIGHT_TOKEN_ID);
        rocolor.changeColorOwner(MURPH_LIGHT_HEX_TRIPLET, FRIEND);
        //// Assert
        address colorOwnerFromStorage =
            getColorOwnerFromStorage(address(rocolor), MURPH_LIGHT_TOKEN_ID, OWNERS_MAPPING_BASE_SLOT);
        assertEq(colorOwnerFromStorage, FRIEND);
    }

    function testChangeColorOwner_HexLength() public {
        // case: length == 0
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorOwner("", FRIEND);

        // case: length == 1
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorOwner("C", FRIEND);

        // case: length == 5
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorOwner("C1B7A", FRIEND);

        // case: length == 6
        vm.prank(HERO);
        rocolor.changeColorOwner("C1B7A0", FRIEND);
        address colorOwnerFromStorage =
            getColorOwnerFromStorage(address(rocolor), MURPH_LIGHT_TOKEN_ID, OWNERS_MAPPING_BASE_SLOT);
        assertEq(colorOwnerFromStorage, FRIEND);

        // case: length == 7
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorOwner("C1B7A02", FRIEND);
    }

    function testChangeColorOwner_HexNumeral() public {
        // case: bad char is first
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorOwner("G1B7A0", FRIEND);

        // case: bad char is middle
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorOwner("C1G7A0", FRIEND);

        // case: bad char is last
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorOwner("C1B7AG", FRIEND);

        // case: bad char is "*""
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorOwner("C1B7*0", FRIEND);

        // case: bad char is a space
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorOwner("C1B7 0", FRIEND);

        // case: bad char is ";""
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorOwner("C1B7;0", FRIEND);

        // case: bad chars are "\\"
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.changeColorOwner("C1\\7A0", FRIEND);
    }

    function testChangeColorOwner_Invalid() public {
        // case: burn address
        vm.expectPartialRevert(ERC721InvalidReceiver.selector);
        vm.prank(HERO);
        rocolor.changeColorOwner(MURPH_LIGHT_HEX_TRIPLET, address(0));
    }

    function testChangeColorOwner_Ownership() public {
        // not minted
        vm.expectPartialRevert(ERC721NonexistentToken.selector);
        vm.prank(HERO);
        rocolor.changeColorOwner("000000", FRIEND);

        // owned by somebody else
        vm.expectPartialRevert(ERC721IncorrectOwner.selector);
        vm.prank(VILLAIN);
        rocolor.changeColorOwner(MURPH_LIGHT_HEX_TRIPLET, FRIEND);
    }

    function testGetColorOwner_HappyPath() public {
        vm.prank(HERO);
        rocolor.getColorOwner(MURPH_LIGHT_HEX_TRIPLET);
        address colorOwnerFromStorage =
            getColorOwnerFromStorage(address(rocolor), MURPH_LIGHT_TOKEN_ID, OWNERS_MAPPING_BASE_SLOT);
        assertEq(colorOwnerFromStorage, HERO);
    }

    function testGetColorOwner_HexLength() public {
        address colorOwnerFromFunction;
        address colorOwnerFromStorage;

        // case: length == 0
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        vm.prank(HERO);
        colorOwnerFromFunction = rocolor.getColorOwner("");

        // case: length == 1
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        vm.prank(HERO);
        colorOwnerFromFunction = rocolor.getColorOwner("C");

        // case: length == 5
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        vm.prank(HERO);
        colorOwnerFromFunction = rocolor.getColorOwner("C1B7A");

        // case: length == 6
        vm.prank(HERO);
        colorOwnerFromFunction = rocolor.getColorOwner("C1B7A0");
        colorOwnerFromStorage =
            getColorOwnerFromStorage(address(rocolor), MURPH_LIGHT_TOKEN_ID, OWNERS_MAPPING_BASE_SLOT);
        assertEq(colorOwnerFromStorage, colorOwnerFromFunction);

        // case: length == 7
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        vm.prank(HERO);
        colorOwnerFromFunction = rocolor.getColorOwner("C1B7A02");
    }

    function testGetColorOwner_HexNumeral() public {
        address colorOwnerFromFunction;

        // case: bad char is first
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        colorOwnerFromFunction = rocolor.getColorOwner("G1B7A0");

        // case: bad char is middle
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        colorOwnerFromFunction = rocolor.getColorOwner("C1G7A0");

        // case: bad char is last
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        colorOwnerFromFunction = rocolor.getColorOwner("C1B7AG");

        // case: bad char is "*""
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        colorOwnerFromFunction = rocolor.getColorOwner("C1B7*0");

        // case: bad char is a space
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        colorOwnerFromFunction = rocolor.getColorOwner("C1B7 0");

        // case: bad char is ";"
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        colorOwnerFromFunction = rocolor.getColorOwner("C1B7;0");

        // case: bad chars are "\\"
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        colorOwnerFromFunction = rocolor.getColorOwner("C1\\7A0");
    }

    function testGetColorOwner_Ownership() public {
        address colorOwnerFromFunction;
        address colorOwnerFromStorage;

        // not minted
        vm.expectPartialRevert(ERC721NonexistentToken.selector);
        vm.prank(HERO);
        colorOwnerFromFunction = rocolor.getColorOwner("000000");
        // colorOwnerFromStorage = getColorOwnerFromStorage(address(rocolor), 0, OWNERS_MAPPING_BASE_SLOT);
        // assertEq(colorOwnerFromStorage, colorOwnerFromFunction);

        // owned by somebody else
        vm.prank(VILLAIN);
        colorOwnerFromFunction = rocolor.getColorOwner(MURPH_LIGHT_HEX_TRIPLET);
        colorOwnerFromStorage =
            getColorOwnerFromStorage(address(rocolor), MURPH_LIGHT_TOKEN_ID, OWNERS_MAPPING_BASE_SLOT);
        assertEq(colorOwnerFromStorage, colorOwnerFromFunction);
    }
}

// notes:
// console.log("FFFFFF is:", decimal);
// {Arrange, Act, Assert}

// backlog:
// TODO (maybe) new owner: invalid (too long, too short) ... seems handled by compiler
// TODO (maybe) reverts if bad calc'd tokenId: size ... fuzz this and assert tokenId size limit?
