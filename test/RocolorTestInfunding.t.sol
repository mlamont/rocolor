// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Rocolor} from "src/Rocolor.sol";
import {DeployRocolor} from "script/DeployRocolor.s.sol";
import {RocolorTestHelpers} from "./RocolorTestHelpers.sol";

contract RocolorTestInfunding is Test, Rocolor, RocolorTestHelpers {
    function setUp() public {
        deployer = new DeployRocolor();
        rocolor = deployer.run();
        vm.deal(HERO, 20 ether);
    }

    function testReceive_HappyPath() public {
        uint256 initialBalance = address(rocolor).balance;
        uint256 sendAmount = 1 ether;

        // Send ETH directly to the contract (triggers receive())
        vm.prank(HERO);
        (bool success,) = payable(address(rocolor)).call{value: sendAmount}("");
        require(success, "Send failed");

        // Verify balance increased
        assertEq(address(rocolor).balance, initialBalance + sendAmount);
    }

    function testReceive_Emits() public {
        uint256 sendAmount = 1 ether;

        vm.prank(HERO);
        vm.expectEmit(true, true, false, true);
        emit ROColor__DepositReceived(HERO, sendAmount);
        (bool success,) = payable(address(rocolor)).call{value: sendAmount}("");
        require(success, "Send failed");
    }

    function testFallback_HappyPath() public {
        uint256 initialBalance = address(rocolor).balance;
        uint256 sendAmount = 1 ether;

        // Send ETH directly to the contract (triggers receive())
        vm.prank(HERO);
        (bool success,) = payable(address(rocolor)).call{value: sendAmount}("nonExistentFunction()");
        require(success, "Send failed");

        // Verify balance increased
        assertEq(address(rocolor).balance, initialBalance + sendAmount);
    }

    function testFallback_Emits() public {
        uint256 sendAmount = 1 ether;

        vm.prank(HERO);
        vm.expectEmit(true, true, false, true);
        emit ROColor__DepositReceived(HERO, sendAmount);
        (bool success,) = payable(address(rocolor)).call{value: sendAmount}("nonExistentFunction()");
        require(success, "Send failed");
    }
}
