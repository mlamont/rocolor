// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Rocolor} from "src/Rocolor.sol";
import {DeployRocolor} from "script/DeployRocolor.s.sol";
import {RocolorTestHelpers} from "./RocolorTestHelpers.sol";
import {StdInvariant} from "lib/forge-std/src/StdInvariant.sol";

contract RocolorFuzzing is StdInvariant, Test, Rocolor, RocolorTestHelpers {
    uint256 private constant COLOR_NAME_MAX_LENGTH = 31;
    uint256 private constant TOKEN_ID_MAX = 16777215;

    function setUp() public {
        deployer = new DeployRocolor();
        rocolor = deployer.run();
        vm.deal(HERO, 10 ether);
        vm.prank(HERO);
        rocolor.mintColor{value: 1 ether}(MURPH_LIGHT_HEX_TRIPLET, MURPH_LIGHT_COLOR_NAME);
    }

    function testFuzz_NameLengthCannotBeOver31(string memory colorName) public {
        vm.assume(bytes(colorName).length > COLOR_NAME_MAX_LENGTH);
        vm.prank(HERO);
        vm.expectPartialRevert(ROColor__ColorNameTooBig.selector);
        rocolor.changeColorName(MURPH_LIGHT_HEX_TRIPLET, colorName);
    }

    function testFuzz_CannotGetUriForTokenOfAtLeast2ToThe24(uint256 tokenId) public {
        vm.assume(tokenId > TOKEN_ID_MAX);
        string memory tokenUri;
        vm.prank(HERO);
        vm.expectPartialRevert(ROColor__TokenIdTooBig.selector);
        tokenUri = rocolor.tokenURI(tokenId);
    }
}
