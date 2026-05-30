// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Rocolor} from "src/Rocolor.sol";
import {DeployRocolor} from "script/DeployRocolor.s.sol";
import {RocolorTestHelpers} from "./RocolorTestHelpers.sol";

contract RocolorTestOutfunding is Test, Rocolor, RocolorTestHelpers {
    function setUp() public {
        deployer = new DeployRocolor();
        rocolor = deployer.run();
        vm.deal(HERO, 20 ether);
    }

    function testWithdraw_HappyPath() public {
        uint256 senderInitialBalance = address(msg.sender).balance;
        uint256 sentAmount = 1 ether;

        vm.prank(HERO);
        rocolor.mintColor{value: sentAmount}(MURPH_LIGHT_HEX_TRIPLET, MURPH_LIGHT_COLOR_NAME);
        vm.prank(address(msg.sender));
        rocolor.withdraw();

        assertEq(address(msg.sender).balance, senderInitialBalance + sentAmount);
    }

    function testWithdraw_Emits() public {
        uint256 minterInitialBalance = address(rocolor).balance;
        uint256 sendAmount = 1 ether;

        vm.prank(HERO);
        rocolor.mintColor{value: sendAmount}(MURPH_LIGHT_HEX_TRIPLET, MURPH_LIGHT_COLOR_NAME);

        vm.prank(address(msg.sender));
        vm.expectEmit(true, false, false, false);
        emit ROColor__ContractBalanceWithdrawalPassed(minterInitialBalance + sendAmount);
        rocolor.withdraw();
    }

    function testWithdraw_HappyLongPath() public {
        uint256 minterInitialBalance = address(rocolor).balance;
        uint256 receiverInitialBalance = address(msg.sender).balance;
        uint256 sendAmount = 1 ether;

        // 1st mint
        vm.prank(HERO);
        rocolor.mintColor{value: sendAmount}(MURPH_LIGHT_HEX_TRIPLET, MURPH_LIGHT_COLOR_NAME);
        // minter contract total funds: 1 ether

        // 2nd mint
        vm.deal(FRIEND, 20 ether);
        vm.prank(FRIEND);
        rocolor.mintColor{value: sendAmount}("000001", "Darkest Blue");
        // minter contract total funds: 2 ether

        // withdraw
        vm.prank(address(msg.sender));
        vm.expectEmit(true, false, false, false);
        emit ROColor__ContractBalanceWithdrawalPassed(minterInitialBalance + sendAmount + sendAmount);
        rocolor.withdraw();
        assertEq(address(rocolor).balance, 0);
        assertEq(address(msg.sender).balance, receiverInitialBalance + minterInitialBalance + sendAmount + sendAmount);

        // 3rd mint
        vm.prank(HERO);
        rocolor.mintColor{value: sendAmount}("000002", "Almost Darkest Blue");
        assertEq(address(rocolor).balance, sendAmount);
    }

    function testWithdraw_Ownership() public {
        uint256 sendAmount = 1 ether;

        vm.prank(HERO);
        rocolor.mintColor{value: sendAmount}(MURPH_LIGHT_HEX_TRIPLET, MURPH_LIGHT_COLOR_NAME);

        vm.prank(VILLAIN);
        vm.expectPartialRevert(OwnableUnauthorizedAccount.selector);
        rocolor.withdraw();
    }

    function testWithdraw_Empty() public {
        vm.prank(address(msg.sender));
        vm.expectPartialRevert(ROColor__ContractBalanceEmpty.selector);
        rocolor.withdraw();
    }
}
