// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Rocolor} from "src/Rocolor.sol";
import {DeployRocolor} from "script/DeployRocolor.s.sol";
import {RocolorTestHelpers} from "./RocolorTestHelpers.sol";
import {StdInvariant} from "lib/forge-std/src/StdInvariant.sol";

contract RocolorFuzzNaming is StdInvariant, Test, Rocolor, RocolorTestHelpers {
    function setUp() public {
        deployer = new DeployRocolor();
        rocolor = deployer.run();
        vm.deal(HERO, 10 ether);
        vm.prank(HERO);
        rocolor.mintColor{value: 1 ether}(MURPH_LIGHT_HEX_TRIPLET, MURPH_LIGHT_COLOR_NAME);
    }

    function invariant_NameLengthIsAlwaysUnder32(string memory colorName) public {
        vm.prank(HERO);
        rocolor.changeColorName(MURPH_LIGHT_HEX_TRIPLET, colorName);
        // gotta use handlers to ensure name always over 31 characters long, so this function always reverts
    }
}
