// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Rocolor} from "src/Rocolor.sol";
import {DeployRocolor} from "script/DeployRocolor.s.sol";
import {RocolorTestHelpers} from "./RocolorTestHelpers.sol";

contract RocolorTestConverting is Test, Rocolor, RocolorTestHelpers {
    // Rocolor rocolor;
    // DeployRocolor deployer;
    // string colorhex;
    // uint256 decimal;
    // uint256 constant MURPH_LIGHT_DECIMAL = 12695456;
    // string constant MURPH_LIGHT_COLORHEX = "C1B7A0";
    // uint256 constant WHITE_DECIMAL = 16777215;
    // uint256 constant BLACK_DECIMAL = 0;

    function setUp() public {
        deployer = new DeployRocolor();
        rocolor = deployer.run();
    }

    function testConvertHexTripletToDecimal_Capitalizations() public {
        // case: all caps
        // Arrange
        hexTriplet = "C1B7A0";
        // Act
        tokenId = rocolor.convertHexTripletToDecimal(hexTriplet);
        // Assert
        assertEq(tokenId, MURPH_LIGHT_TOKEN_ID);

        // case: all lowercase
        hexTriplet = "c1b7a0";
        tokenId = rocolor.convertHexTripletToDecimal(hexTriplet);
        assertEq(tokenId, MURPH_LIGHT_TOKEN_ID);

        // case: mixed case
        hexTriplet = "C1b7A0";
        tokenId = rocolor.convertHexTripletToDecimal(hexTriplet);
        assertEq(tokenId, MURPH_LIGHT_TOKEN_ID);
    }

    function testConvertHexTripletToDecimal_Bounds() public {
        // case: lowest
        hexTriplet = "000000";
        tokenId = rocolor.convertHexTripletToDecimal(hexTriplet);
        assertEq(tokenId, BLACK_TOKEN_ID);

        // case: highest
        hexTriplet = "FFFFFF";
        tokenId = rocolor.convertHexTripletToDecimal(hexTriplet);
        assertEq(tokenId, WHITE_TOKEN_ID);
    }

    function testConvertHexTripletToDecimal_Length() public {
        // case: length == 0
        hexTriplet = "";
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        tokenId = rocolor.convertHexTripletToDecimal(hexTriplet);
        console.log("reverted length == 0");

        // case: length == 1
        hexTriplet = "a";
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        tokenId = rocolor.convertHexTripletToDecimal(hexTriplet);
        console.log("reverted length == 1");

        // case: length == 5
        hexTriplet = "a1b2c";
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        tokenId = rocolor.convertHexTripletToDecimal(hexTriplet);
        console.log("reverted length == 5");

        // case: length == 7
        hexTriplet = "a1b2c3d";
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        tokenId = rocolor.convertHexTripletToDecimal(hexTriplet);
        console.log("reverted length == 7");
    }

    function testConvertHexTripletToDecimal_Characters() public {
        // case: bad character is first
        hexTriplet = "g1b2c3";
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        tokenId = rocolor.convertHexTripletToDecimal(hexTriplet);

        // case: bad character is last
        hexTriplet = "a1b2cg";
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        tokenId = rocolor.convertHexTripletToDecimal(hexTriplet);

        // case: bad character is in the middle
        hexTriplet = "a1g2c3";
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        tokenId = rocolor.convertHexTripletToDecimal(hexTriplet);

        // case: bad character is *
        hexTriplet = "*1b2c3";
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        tokenId = rocolor.convertHexTripletToDecimal(hexTriplet);

        // case: bad character is [space]
        hexTriplet = "a1b c3";
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        tokenId = rocolor.convertHexTripletToDecimal(hexTriplet);
        console.log("reverted bad character is [space]");

        // case: bad character is ;
        hexTriplet = "a1b;c3";
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        tokenId = rocolor.convertHexTripletToDecimal(hexTriplet);
    }

    function testConvertDecimalToHexTriplet() public {
        // case: a happy path
        tokenId = MURPH_LIGHT_TOKEN_ID;
        hexTriplet = rocolor.convertDecimalToHexTriplet(tokenId);
        assertEq(hexTriplet, MURPH_LIGHT_HEX_TRIPLET);
        console.log("accepted happy path");

        // case: smallest
        tokenId = BLACK_TOKEN_ID;
        hexTriplet = rocolor.convertDecimalToHexTriplet(tokenId);
        assertEq(hexTriplet, "000000");
        console.log("accepted smallest");

        // case: too big
        tokenId = WHITE_TOKEN_ID + 1;
        vm.expectPartialRevert(ROColor__TokenIdTooBig.selector);
        hexTriplet = rocolor.convertDecimalToHexTriplet(tokenId);
        console.log("reverted too big");

        // case: biggest
        tokenId = WHITE_TOKEN_ID;
        hexTriplet = rocolor.convertDecimalToHexTriplet(tokenId);
        assertEq(hexTriplet, "FFFFFF");
        console.log("accepted largest");
    }
}

// notes:
// console.log("FFFFFF is:", decimal);
// {Arrange, Act, Assert}

// backlog:
// TODO fuzz testing for convertColorhexToDecimal()
