// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {Test} from "lib/forge-std/src/Test.sol";
import {Rocolor} from "src/Rocolor.sol";

contract RocolorTest is Test, Rocolor {
    Rocolor rocolor;
    string colorhex;
    uint256 decimal;
    uint256 constant MURPH_LIGHT = 12695456;
    uint256 constant WHITE = 16777215;
    uint256 constant BLACK = 0;

    function setUp() public {
        rocolor = new Rocolor();
    }

    function testConvertColorhexToDecimal_Capitalizations() public {
        // case: all caps
        // Arrange
        colorhex = "C1B7A0";
        // Act
        decimal = rocolor.convertColorhexToDecimal(colorhex);
        // Assert
        assertEq(decimal, MURPH_LIGHT);

        // case: all lowercase
        colorhex = "c1b7a0";
        decimal = rocolor.convertColorhexToDecimal(colorhex);
        assertEq(decimal, MURPH_LIGHT);

        // case: mixed case
        colorhex = "C1b7A0";
        decimal = rocolor.convertColorhexToDecimal(colorhex);
        assertEq(decimal, MURPH_LIGHT);
    }

    function testConvertColorhexToDecimal_Bounds() public {
        // case: lowest
        colorhex = "000000";
        decimal = rocolor.convertColorhexToDecimal(colorhex);
        assertEq(decimal, BLACK);

        // case: highest
        colorhex = "FFFFFF";
        decimal = rocolor.convertColorhexToDecimal(colorhex);
        assertEq(decimal, WHITE);
    }

    function testConvertColorhexToDecimal_Length() public {
        // case: length == 0
        colorhex = "";
        vm.expectPartialRevert(ROColor__ColorhexLengthInvalid.selector);
        decimal = rocolor.convertColorhexToDecimal(colorhex);

        // case: length == 1
        colorhex = "a";
        vm.expectPartialRevert(ROColor__ColorhexLengthInvalid.selector);
        decimal = rocolor.convertColorhexToDecimal(colorhex);

        // case: length == 5
        colorhex = "a1b2c";
        vm.expectPartialRevert(ROColor__ColorhexLengthInvalid.selector);
        decimal = rocolor.convertColorhexToDecimal(colorhex);

        // case: length == 7
        colorhex = "a1b2c3d";
        vm.expectPartialRevert(ROColor__ColorhexLengthInvalid.selector);
        decimal = rocolor.convertColorhexToDecimal(colorhex);
    }

    function testConvertColorhexToDecimal_Characters() public {
        // case: bad character is first
        colorhex = "g1b2c3";
        vm.expectPartialRevert(ROColor__ColorhexCharacterInvalid.selector);
        decimal = rocolor.convertColorhexToDecimal(colorhex);

        // case: bad character is last
        colorhex = "a1b2cg";
        vm.expectPartialRevert(ROColor__ColorhexCharacterInvalid.selector);
        decimal = rocolor.convertColorhexToDecimal(colorhex);

        // case: bad character is in the middle
        colorhex = "a1g2c3";
        vm.expectPartialRevert(ROColor__ColorhexCharacterInvalid.selector);
        decimal = rocolor.convertColorhexToDecimal(colorhex);

        // case: bad character is *
        colorhex = "*1b2c3";
        vm.expectPartialRevert(ROColor__ColorhexCharacterInvalid.selector);
        decimal = rocolor.convertColorhexToDecimal(colorhex);

        // case: bad character is [space]
        colorhex = "a1b c3";
        vm.expectPartialRevert(ROColor__ColorhexCharacterInvalid.selector);
        decimal = rocolor.convertColorhexToDecimal(colorhex);

        // case: bad character is ;
        colorhex = "a1b;c3";
        vm.expectPartialRevert(ROColor__ColorhexCharacterInvalid.selector);
        decimal = rocolor.convertColorhexToDecimal(colorhex);
    }
}

// notes:
// console.log("FFFFFF is:", decimal);
// {Arrange, Act, Assert}

// backlog:
// fuzz testing for convertColorhexToDecimal()
