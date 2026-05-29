// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Rocolor} from "src/Rocolor.sol";
import {DeployRocolor} from "script/DeployRocolor.s.sol";
import {RocolorTestHelpers} from "./RocolorTestHelpers.sol";

contract RocolorTestBurning is Test, Rocolor, RocolorTestHelpers {
    // Rocolor rocolor;
    // DeployRocolor deployer;
    // string hexTriplet;
    // uint256 tokenId;
    // address HERO = makeAddr("hero");
    // address VILLAIN = makeAddr("villain");
    // address FRIEND = makeAddr("friend");
    // uint256 constant MURPH_LIGHT_TOKEN_ID = 12695456;
    // string constant MURPH_LIGHT_HEX_TRIPLET = "C1B7A0";
    // string constant MURPH_LIGHT_COLOR_NAME = "MurphLight";
    // string constant SUPER_BORING_COLOR_NAME = "Super Boring";
    // uint256 constant WHITE_TOKEN_ID = 16777215;
    // uint256 constant BLACK_TOKEN_ID = 0;
    // uint256 constant OWNERS_MAPPING_BASE_SLOT = 2;
    // uint256 constant COLOR_NAMES_MAPPING_BASE_SLOT = 7;
    // uint256 constant MURPH_PRICE = 0.001 ether;
    // uint256 constant RED_PRICE = 1 ether;
    // uint256 constant WHITE_PRICE = 10 ether;
    // bytes32 constant NO_COLOR_NAME_EVENT_TOPIC = keccak256("");
    // bytes32 constant MURPH_LIGHT_COLOR_NAME_EVENT_TOPIC = keccak256("MurphLight");

    function setUp() public {
        deployer = new DeployRocolor();
        rocolor = deployer.run();
        vm.deal(HERO, 10 ether);
        vm.prank(HERO);
        rocolor.mintColor{value: 1 ether}(MURPH_LIGHT_HEX_TRIPLET, MURPH_LIGHT_COLOR_NAME);
    }

    function testBurnColor_HappyPath() public {
        vm.prank(HERO);
        rocolor.burnColor(MURPH_LIGHT_HEX_TRIPLET);
        string memory colorNameFromStorage =
            getColorNameFromStorage(address(rocolor), MURPH_LIGHT_TOKEN_ID, COLOR_NAMES_MAPPING_BASE_SLOT);
        assertEq(colorNameFromStorage, "");
        address colorOwnerFromStorage =
            getColorOwnerFromStorage(address(rocolor), MURPH_LIGHT_TOKEN_ID, OWNERS_MAPPING_BASE_SLOT);
        assertEq(colorOwnerFromStorage, address(0));
    }

    function testBurnColor_TransferEvent() public {
        vm.prank(HERO);
        vm.expectEmit();
        emit Transfer(HERO, address(0), MURPH_LIGHT_TOKEN_ID);
        rocolor.burnColor(MURPH_LIGHT_HEX_TRIPLET);
    }

    function testBurnColor_RenameEvent() public {
        vm.prank(HERO);
        vm.expectEmit();
        emit ROColor__Rename(MURPH_LIGHT_COLOR_NAME, "", MURPH_LIGHT_TOKEN_ID);
        rocolor.burnColor(MURPH_LIGHT_HEX_TRIPLET);
    }

    function testBurnColor_HexLength() public {
        // case: length == 0
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        vm.prank(HERO);
        rocolor.burnColor("");

        // case: length == 1
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        vm.prank(HERO);
        rocolor.burnColor("C");

        // case: length == 5
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        vm.prank(HERO);
        rocolor.burnColor("C1B7A");

        // case: length == 6
        vm.prank(HERO);
        rocolor.burnColor("C1B7A0");
        string memory colorNameFromStorage =
            getColorNameFromStorage(address(rocolor), MURPH_LIGHT_TOKEN_ID, COLOR_NAMES_MAPPING_BASE_SLOT);
        assertEq(colorNameFromStorage, "");
        address colorOwnerFromStorage =
            getColorOwnerFromStorage(address(rocolor), MURPH_LIGHT_TOKEN_ID, OWNERS_MAPPING_BASE_SLOT);
        assertEq(colorOwnerFromStorage, address(0));

        // case: length == 7
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        vm.prank(HERO);
        rocolor.burnColor("C1B7A02");
    }

    function testBurnColor_HexNumeral() public {
        // case: bad char is first
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.burnColor("G1B7A0");

        // case: bad char is middle
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.burnColor("C1G7A0");

        // case: bad char is last
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.burnColor("C1B7AG");

        // case: bad char is "*""
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.burnColor("C1B7*0");

        // case: bad char is a space
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.burnColor("C1B7 0");

        // case: bad char is ";"
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.burnColor("C1B7;0");

        // case: bad char is "\\"
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        vm.prank(HERO);
        rocolor.burnColor("C1\\7A0");
    }

    function testBurnColor_Ownership() public {
        // case: not minted
        vm.prank(HERO);
        vm.expectPartialRevert(ERC721NonexistentToken.selector);
        rocolor.burnColor("000000");

        // case: owned by someone else
        vm.prank(VILLAIN);
        vm.expectPartialRevert(ERC721IncorrectOwner.selector);
        rocolor.burnColor(MURPH_LIGHT_HEX_TRIPLET);
    }
}

// backlog:
// TODO (maybe) Reverts if calculated tokenId is 2^24 or greater
