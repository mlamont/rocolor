// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Rocolor} from "src/Rocolor.sol";
import {DeployRocolor} from "script/DeployRocolor.s.sol";
import {RocolorTestHelpers} from "./RocolorTestHelpers.sol";

contract RocolorTestMinting is Test, Rocolor, RocolorTestHelpers {
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
    uint256 constant MURPH_PRICE = 0.001 ether;
    uint256 constant RED_PRICE = 1 ether;
    uint256 constant WHITE_PRICE = 10 ether;
    // bytes32 constant NO_COLOR_NAME_EVENT_TOPIC = keccak256("");
    // bytes32 constant MURPH_LIGHT_COLOR_NAME_EVENT_TOPIC = keccak256("MurphLight");

    function setUp() public {
        deployer = new DeployRocolor();
        rocolor = deployer.run();
        vm.deal(HERO, 20 ether);
    }

    function testMintColor_HappyPath() public {
        vm.prank(HERO);
        rocolor.mintColor{value: 1 ether}(MURPH_LIGHT_HEX_TRIPLET, MURPH_LIGHT_COLOR_NAME);
        string memory colorNameFromStorage =
            getColorNameFromStorage(address(rocolor), MURPH_LIGHT_TOKEN_ID, COLOR_NAMES_MAPPING_BASE_SLOT);
        assertEq(colorNameFromStorage, MURPH_LIGHT_COLOR_NAME);
        address colorOwnerFromStorage =
            getColorOwnerFromStorage(address(rocolor), MURPH_LIGHT_TOKEN_ID, OWNERS_MAPPING_BASE_SLOT);
        assertEq(colorOwnerFromStorage, HERO);
    }

    function testMintColor_TransferEvent() public {
        vm.prank(HERO);
        vm.expectEmit();
        emit Transfer(address(0), HERO, MURPH_LIGHT_TOKEN_ID);
        rocolor.mintColor{value: 1 ether}(MURPH_LIGHT_HEX_TRIPLET, MURPH_LIGHT_COLOR_NAME);
    }

    function testMintColor_RenameEvent() public {
        vm.prank(HERO);
        vm.expectEmit();
        emit ROColor__Rename("", MURPH_LIGHT_COLOR_NAME, MURPH_LIGHT_TOKEN_ID);
        rocolor.mintColor{value: 1 ether}(MURPH_LIGHT_HEX_TRIPLET, MURPH_LIGHT_COLOR_NAME);
    }
}

// backlog
// / Happy Path
// / Emits a Transfer event
// / Emits a ROColor__Rename event
// Reverts if hex triplet is not exactly 6 bytes
// Reverts if a hex triplet byte is not a hexadecimal numeral
// Reverts if name length is over 31 bytes
// Reverts if funds are less than the price of the color token
// Reverts if minting to the burn address
// Reverts if token already exists
// TODO (maybe) Reverts if calculated tokenId is 2^24 or greater
