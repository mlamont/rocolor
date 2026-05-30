// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Rocolor} from "src/Rocolor.sol";
import {DeployRocolor} from "script/DeployRocolor.s.sol";
import {RocolorTestHelpers} from "./RocolorTestHelpers.sol";

contract RocolorTestPricing is Test, Rocolor, RocolorTestHelpers {
    function setUp() public {
        deployer = new DeployRocolor();
        rocolor = deployer.run();
        vm.deal(HERO, 10 ether);
        vm.prank(HERO);
        rocolor.mintColor{value: 1 ether}(MURPH_LIGHT_HEX_TRIPLET, MURPH_LIGHT_COLOR_NAME);
    }

    function testGetColorPrice_HappyPath() public view {
        uint256 colorPrice = rocolor.getColorPrice(MURPH_LIGHT_HEX_TRIPLET);
        assertEq(colorPrice, MURPH_PRICE);
    }

    function testGetColorPrice_HappyOptions() public view {
        uint256 colorPrice;

        // case: red
        colorPrice = rocolor.getColorPrice("FF0000");
        assertEq(colorPrice, RED_PRICE);

        // case: white
        colorPrice = rocolor.getColorPrice("FFFFFF");
        assertEq(colorPrice, WHITE_PRICE);
    }

    function testGetColorPrice_HexLength() public {
        uint256 colorPrice;

        // case: length == 0
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        colorPrice = rocolor.getColorPrice("");

        // case: length == 1
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        colorPrice = rocolor.getColorPrice("C");

        // case: length == 5
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        colorPrice = rocolor.getColorPrice("C1B7A");

        // case: length == 6
        colorPrice = rocolor.getColorPrice("C1B7A0");
        assertEq(colorPrice, MURPH_PRICE);

        // case: length == 7
        vm.expectPartialRevert(ROColor__HexTripletLengthInvalid.selector);
        colorPrice = rocolor.getColorPrice("C1B7A02");
    }

    function testGetColorPrice_HexNumeral() public {
        uint256 colorPrice;

        // case: bad char is first
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        colorPrice = rocolor.getColorPrice("G1B7A0");

        // case: bad char is middle
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        colorPrice = rocolor.getColorPrice("C1G7A0");

        // case: bad char is last
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        colorPrice = rocolor.getColorPrice("C1B7AG");

        // case: bad char is "*""
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        colorPrice = rocolor.getColorPrice("C1B7*0");

        // case: bad char is a space
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        colorPrice = rocolor.getColorPrice("C1B7 0");

        // case: bad char is ";""
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        colorPrice = rocolor.getColorPrice("C1B7;0");

        // case: bad chars are "\\"
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        colorPrice = rocolor.getColorPrice("C1\\7A0");
    }

    function testGetColorPrice_Ownership() public {
        uint256 colorPrice;

        // case: not minted
        colorPrice = rocolor.getColorPrice("FFFFFF");
        assertEq(colorPrice, WHITE_PRICE);

        // case: owned by somebody else
        vm.prank(VILLAIN);
        colorPrice = rocolor.getColorPrice(MURPH_LIGHT_HEX_TRIPLET);
        assertEq(colorPrice, MURPH_PRICE);
    }
}
