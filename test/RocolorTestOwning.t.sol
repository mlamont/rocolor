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
}

// notes:
// console.log("FFFFFF is:", decimal);
// {Arrange, Act, Assert}

// backlog:
// happy path: change owner
// emits: transfer
// reverts: hex length: not 6 (0, 1, 5, 6, 7)
// reverts: hex member: not 0-F (first, ..., \\)
// reverts: new owner: invalid (too long, too short)
// reverts: new owner: burn
// reverts: owner: none (not minted)
// reverts: owner: somebody else (owned by somebody else)
// happy path: get owner
// reverts: hex length: not 6 (0, 1, 5, 6, 7)
// reverts: hex member: not 0-F (first, ..., \\)
// reverts: owner: none (not minted)
// OK: owner: somebody else (owned by somebody else)

// TODO (maybe?) reverts if bad calc'd tokenId: size ... fuzz this and assert tokenId size limit?
