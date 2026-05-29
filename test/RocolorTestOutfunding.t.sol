// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Rocolor} from "src/Rocolor.sol";
import {DeployRocolor} from "script/DeployRocolor.s.sol";
import {RocolorTestHelpers} from "./RocolorTestHelpers.sol";

contract RocolorTestOutfunding is Test, Rocolor, RocolorTestHelpers {
    // Rocolor rocolor;
    // DeployRocolor deployer;
    // string hexTriplet;
    // uint256 tokenId;
    // address HERO = makeAddr("hero");
    // address VILLAIN = makeAddr("villain");
    // address FRIEND = makeAddr("friend");
    // uint256 constant MURPH_LIGHT_TOKEN_ID = 12695456;
    // string constant MURPH_LIGHT_HEX_TRIPLET = "C1B7A0";
    // string constant MURPH_LIGHT_COLOR_NAME = "MurphLight";
    // string constant SUPER_BORING_COLOR_NAME = "Super Boring";
    // uint256 constant WHITE_TOKEN_ID = 16777215;
    // uint256 constant BLACK_TOKEN_ID = 0;
    // uint256 constant OWNERS_MAPPING_BASE_SLOT = 2;
    // uint256 constant COLOR_NAMES_MAPPING_BASE_SLOT = 7;
    // uint256 constant MURPH_PRICE = 0.001 ether;
    // uint256 constant RED_PRICE = 1 ether;
    // uint256 constant WHITE_PRICE = 10 ether;
    // bytes32 constant NO_COLOR_NAME_EVENT_TOPIC = keccak256("");
    // bytes32 constant MURPH_LIGHT_COLOR_NAME_EVENT_TOPIC = keccak256("MurphLight");

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
// backlog
// TODO Reverts if fund withdrawal failed (2 ways)
// TODO stops reentrancy

