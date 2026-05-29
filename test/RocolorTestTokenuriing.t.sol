// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Rocolor} from "src/Rocolor.sol";
import {DeployRocolor} from "script/DeployRocolor.s.sol";
import {RocolorTestHelpers} from "./RocolorTestHelpers.sol";

contract RocolorTestTokenuriing is Test, Rocolor, RocolorTestHelpers {
    function setUp() public {
        deployer = new DeployRocolor();
        rocolor = deployer.run();
        vm.deal(HERO, 20 ether);
    }

    function testTokenuri_Revert() public {
        vm.prank(HERO);
        vm.expectPartialRevert(ROColor__TokenIdTooBig.selector);
        rocolor.tokenURI(WHITE_TOKEN_ID + 1);
    }

    function testTokenuri_Metadata() public {
        string memory tokenUriFromFunction;
        string memory tokenUriFromConstruction;

        vm.prank(HERO);
        rocolor.mintColor{value: 1 ether}(MURPH_LIGHT_HEX_TRIPLET, MURPH_LIGHT_COLOR_NAME);
        tokenUriFromFunction = rocolor.tokenURI(MURPH_LIGHT_TOKEN_ID);
        tokenUriFromConstruction = string(abi.encodePacked("data:application/json;base64,", ENCODED_JSON));
        assertEq(tokenUriFromFunction, tokenUriFromConstruction);
    }
}
