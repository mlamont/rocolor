// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {Script} from "forge-std/Script.sol";
import {Rocolor} from "../src/Rocolor.sol";

contract DeployRocolor is Script {
    function run() external returns (Rocolor) {
        vm.startBroadcast();
        Rocolor rocolor = new Rocolor();
        vm.stopBroadcast();
        return rocolor;
    }
}
