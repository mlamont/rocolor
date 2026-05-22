// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Rocolor} from "src/Rocolor.sol";
import {DeployRocolor} from "script/DeployRocolor.s.sol";

contract RocolorTestConverting is Test, Rocolor {
    Rocolor rocolor;
    DeployRocolor deployer;
    string hexTriplet;
    uint256 tokenId;
    uint256 constant MURPH_LIGHT_TOKEN_ID = 12695456;
    string constant MURPH_LIGHT_HEX_TRIPLET = "C1B7A0";
    uint256 constant WHITE_TOKEN_ID = 16777215;
    uint256 constant BLACK_TOKEN_ID = 0;

    function setUp() public {
        deployer = new DeployRocolor();
        rocolor = deployer.run();
        // gotta prank a token already being minted & named
    }

    function testChangeColorName_HappyPath() public {
        // Arrange
        // colorhex = "C1B7A0";

        // Act
        // decimal = rocolor.convertHexTripletToDecimal(colorhex);

        // Assert
        // assertEq(decimal, MURPH_LIGHT_DECIMAL);
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
