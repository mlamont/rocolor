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
    uint256 private constant HEX_TRIPLET_VALID_LENGTH = 6;

    function setUp() public {
        deployer = new DeployRocolor();
        rocolor = deployer.run();
    }

    function testFuzz_NameLengthCannotBeOver31(string memory colorName) public {
        vm.assume(bytes(colorName).length > COLOR_NAME_MAX_LENGTH); // cannot use bound() for this line
        vm.deal(HERO, 10 ether);
        vm.prank(HERO);
        rocolor.mintColor{value: 1 ether}(MURPH_LIGHT_HEX_TRIPLET, MURPH_LIGHT_COLOR_NAME);
        vm.prank(HERO);
        vm.expectPartialRevert(ROColor__ColorNameTooBig.selector);
        rocolor.changeColorName(MURPH_LIGHT_HEX_TRIPLET, colorName);
    }

    function testFuzz_CannotGetUriForTokenOfAtLeast2ToThe24(uint256 tokenId) public {
        tokenId = bound(tokenId, TOKEN_ID_MAX + 1, UINT256_MAX); // better than vm.assume() for this line
        string memory tokenUri;
        vm.prank(HERO);
        vm.expectPartialRevert(ROColor__TokenIdTooBig.selector);
        tokenUri = rocolor.tokenURI(tokenId);
    }

    function testFuzz_ValidHexTripletAlwaysConvertsToTokenIdUnder2ToThe24(uint256 seed) public view {
        seed = bound(seed, 0, TOKEN_ID_MAX);
        string memory hexTriplet = rocolor.convertDecimalToHexTriplet(seed);
        uint256 tokenId = rocolor.convertHexTripletToDecimal(hexTriplet);
        assert(tokenId <= TOKEN_ID_MAX);
    }

    function testFuzz_OnlyValidHexNumeralsAccepted(string memory seed) public {
        vm.assume(bytes(seed).length >= HEX_TRIPLET_VALID_LENGTH); // cannot use bound() for this line
        bytes memory hexTripletBytes = new bytes(HEX_TRIPLET_VALID_LENGTH);
        for (uint256 i; i < HEX_TRIPLET_VALID_LENGTH; ++i) {
            hexTripletBytes[i] = bytes(seed)[i];
        }
        uint8 val = uint8(hexTripletBytes[0]);
        vm.assume(!((val >= 0x30 && val <= 0x39) || (val >= 0x61 && val <= 0x66) || (val >= 0x41 && val <= 0x46)));
        uint256 tokenId;
        vm.expectPartialRevert(ROColor__HexTripletNumeralInvalid.selector);
        tokenId = rocolor.convertHexTripletToDecimal(string(hexTripletBytes));
    }

    function testFuzz_OnlyContractOwnerCanWithdraw(address seed) public {
        vm.deal(HERO, 10 ether);
        vm.prank(HERO);
        rocolor.mintColor{value: 1 ether}(MURPH_LIGHT_HEX_TRIPLET, MURPH_LIGHT_COLOR_NAME);
        vm.assume(seed != msg.sender);
        vm.prank(seed);
        vm.expectPartialRevert(OwnableUnauthorizedAccount.selector);
        rocolor.withdraw();
    }

    function testFuzz_OnlyColorOwnerCanRename(address seed) public {
        vm.deal(HERO, 10 ether);
        vm.prank(HERO);
        rocolor.mintColor{value: 1 ether}(MURPH_LIGHT_HEX_TRIPLET, MURPH_LIGHT_COLOR_NAME);
        vm.assume(seed != HERO);
        vm.prank(seed);
        vm.expectPartialRevert(ERC721IncorrectOwner.selector);
        rocolor.changeColorName(MURPH_LIGHT_HEX_TRIPLET, SUPER_BORING_COLOR_NAME);
    }

    function testFuzz_OnlyColorOwnerCanReown(address seed) public {
        vm.deal(HERO, 10 ether);
        vm.prank(HERO);
        rocolor.mintColor{value: 1 ether}(MURPH_LIGHT_HEX_TRIPLET, MURPH_LIGHT_COLOR_NAME);
        vm.assume(seed != HERO);
        vm.assume(seed != address(0));
        vm.prank(seed);
        vm.expectPartialRevert(ERC721IncorrectOwner.selector);
        rocolor.changeColorOwner(MURPH_LIGHT_HEX_TRIPLET, seed);
    }

    function testFuzz_OnlyColorOwnerCanBurn(address seed) public {
        vm.deal(HERO, 10 ether);
        vm.prank(HERO);
        rocolor.mintColor{value: 1 ether}(MURPH_LIGHT_HEX_TRIPLET, MURPH_LIGHT_COLOR_NAME);
        vm.assume(seed != HERO);
        vm.assume(seed != address(0));
        vm.prank(seed);
        vm.expectPartialRevert(ERC721IncorrectOwner.selector);
        rocolor.burnColor(MURPH_LIGHT_HEX_TRIPLET);
    }
}
