// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Rocolor} from "src/Rocolor.sol";
import {DeployRocolor} from "script/DeployRocolor.s.sol";

contract RocolorTest is Test, Rocolor {
    Rocolor rocolor;
    DeployRocolor deployer;
    string colorhex;
    uint256 decimal;
    uint256 constant MURPH_LIGHT_DECIMAL = 12695456;
    string constant MURPH_LIGHT_COLORHEX = "C1B7A0";
    uint256 constant WHITE_DECIMAL = 16777215;
    uint256 constant BLACK_DECIMAL = 0;

    function setUp() public {
        deployer = new DeployRocolor();
        rocolor = deployer.run();
    }

    function testConvertColorhexToDecimal_Capitalizations() public {
        // case: all caps
        // Arrange
        colorhex = "C1B7A0";
        // Act
        decimal = rocolor.convertColorhexToDecimal(colorhex);
        // Assert
        assertEq(decimal, MURPH_LIGHT_DECIMAL);

        // case: all lowercase
        colorhex = "c1b7a0";
        decimal = rocolor.convertColorhexToDecimal(colorhex);
        assertEq(decimal, MURPH_LIGHT_DECIMAL);

        // case: mixed case
        colorhex = "C1b7A0";
        decimal = rocolor.convertColorhexToDecimal(colorhex);
        assertEq(decimal, MURPH_LIGHT_DECIMAL);
    }

    function testConvertColorhexToDecimal_Bounds() public {
        // case: lowest
        colorhex = "000000";
        decimal = rocolor.convertColorhexToDecimal(colorhex);
        assertEq(decimal, BLACK_DECIMAL);

        // case: highest
        colorhex = "FFFFFF";
        decimal = rocolor.convertColorhexToDecimal(colorhex);
        assertEq(decimal, WHITE_DECIMAL);
    }

    function testConvertColorhexToDecimal_Length() public {
        // case: length == 0
        colorhex = "";
        vm.expectPartialRevert(ROColor__ColorhexLengthInvalid.selector);
        decimal = rocolor.convertColorhexToDecimal(colorhex);
        console.log("reverted length == 0");

        // case: length == 1
        colorhex = "a";
        vm.expectPartialRevert(ROColor__ColorhexLengthInvalid.selector);
        decimal = rocolor.convertColorhexToDecimal(colorhex);
        console.log("reverted length == 1");

        // case: length == 5
        colorhex = "a1b2c";
        vm.expectPartialRevert(ROColor__ColorhexLengthInvalid.selector);
        decimal = rocolor.convertColorhexToDecimal(colorhex);
        console.log("reverted length == 5");

        // case: length == 7
        colorhex = "a1b2c3d";
        vm.expectPartialRevert(ROColor__ColorhexLengthInvalid.selector);
        decimal = rocolor.convertColorhexToDecimal(colorhex);
        console.log("reverted length == 7");
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
        console.log("reverted bad character is [space]");

        // case: bad character is ;
        colorhex = "a1b;c3";
        vm.expectPartialRevert(ROColor__ColorhexCharacterInvalid.selector);
        decimal = rocolor.convertColorhexToDecimal(colorhex);
    }

    function testConvertDecimalToColorhex() public {
        // case: a happy path
        decimal = MURPH_LIGHT_DECIMAL;
        colorhex = rocolor.convertDecimalToColorhex(decimal);
        assertEq(colorhex, MURPH_LIGHT_COLORHEX);
        console.log("accepted happy path");

        // case: smallest
        decimal = BLACK_DECIMAL;
        colorhex = rocolor.convertDecimalToColorhex(decimal);
        assertEq(colorhex, "000000");
        console.log("accepted smallest");

        // case: too big
        decimal = WHITE_DECIMAL + 1;
        vm.expectPartialRevert(ROColor__DecimalTooBig.selector);
        colorhex = rocolor.convertDecimalToColorhex(decimal);
        console.log("reverted too big");

        // case: biggest
        decimal = WHITE_DECIMAL;
        colorhex = rocolor.convertDecimalToColorhex(decimal);
        assertEq(colorhex, "FFFFFF");
        console.log("accepted largest");
    }
}

// notes:
// console.log("FFFFFF is:", decimal);
// {Arrange, Act, Assert}

// backlog:
// fuzz testing for convertColorhexToDecimal()
