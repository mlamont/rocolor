// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {Test} from "lib/forge-std/src/Test.sol";
import {Rocolor} from "src/Rocolor.sol";
import {DeployRocolor} from "script/DeployRocolor.s.sol";

contract RocolorTestHelpers is Test {
    Rocolor rocolor;
    DeployRocolor deployer;
    string hexTriplet;
    uint256 tokenId;
    address HERO = makeAddr("hero");
    address VILLAIN = makeAddr("villain");
    address FRIEND = makeAddr("friend");
    uint256 constant MURPH_LIGHT_TOKEN_ID = 12695456;
    string constant MURPH_LIGHT_HEX_TRIPLET = "C1B7A0";
    string constant MURPH_LIGHT_COLOR_NAME = "MurphLight";
    string constant SUPER_BORING_COLOR_NAME = "Super Boring";
    uint256 constant WHITE_TOKEN_ID = 16777215;
    uint256 constant BLACK_TOKEN_ID = 0;
    uint256 constant OWNERS_MAPPING_BASE_SLOT = 2;
    uint256 constant COLOR_NAMES_MAPPING_BASE_SLOT = 7;
    uint256 constant MURPH_PRICE = 0.001 ether;
    uint256 constant RED_PRICE = 1 ether;
    uint256 constant WHITE_PRICE = 10 ether;
    string constant ENCODED_SVG =
        "PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHByZXNlcnZlQXNwZWN0UmF0aW89InhNaW5ZTWluIG1lZXQiIHZpZXdCb3g9IjAgMCAzNTAgMzUwIj48c3R5bGU+LmJhc2UgeyBmaWxsOiB3aGl0ZTsgZm9udC1mYW1pbHk6IHNlcmlmOyBmb250LXNpemU6IDE0cHg7IH08L3N0eWxlPjxyZWN0IHdpZHRoPSIxMDAlIiBoZWlnaHQ9IjEwMCUiIGZpbGw9ImJsYWNrIiAvPjx0ZXh0IHg9IjUwJSIgeT0iMTYiIHRleHQtYW5jaG9yPSJtaWRkbGUiIHJvdGF0ZT0iMTgwIiBzdHlsZT0iZmlsbDogYmxhY2s7IGZvbnQtc2l6ZTogMzVweDsiPiYjOTgxNDs8L3RleHQ+PHRleHQgeD0iNTAlIiB5PSIzMjAiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGNsYXNzPSJiYXNlIj5NdXJwaExpZ2h0PC90ZXh0Pjx0ZXh0IHg9IjUwJSIgeT0iMzM3IiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBjbGFzcz0iYmFzZSI+I0MxQjdBMDwvdGV4dD48cmVjdCB4PSI1MCIgeT0iNTAiIHdpZHRoPSIyNTAiIGhlaWdodD0iMjUwIiBmaWxsPSIjQzFCN0EwIiAvPjwvc3ZnPg==";
    string constant ENCODED_JSON =
        "eyJuYW1lIjogIk11cnBoTGlnaHQiLCAiZGVzY3JpcHRpb24iOiAiYSBST0NvbG9yIGZvciBvbmNoYWluIGFydCIsICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSEJ5WlhObGNuWmxRWE53WldOMFVtRjBhVzg5SW5oTmFXNVpUV2x1SUcxbFpYUWlJSFpwWlhkQ2IzZzlJakFnTUNBek5UQWdNelV3SWo0OGMzUjViR1UrTG1KaGMyVWdleUJtYVd4c09pQjNhR2wwWlRzZ1ptOXVkQzFtWVcxcGJIazZJSE5sY21sbU95Qm1iMjUwTFhOcGVtVTZJREUwY0hnN0lIMDhMM04wZVd4bFBqeHlaV04wSUhkcFpIUm9QU0l4TURBbElpQm9aV2xuYUhROUlqRXdNQ1VpSUdacGJHdzlJbUpzWVdOcklpQXZQangwWlhoMElIZzlJalV3SlNJZ2VUMGlNVFlpSUhSbGVIUXRZVzVqYUc5eVBTSnRhV1JrYkdVaUlISnZkR0YwWlQwaU1UZ3dJaUJ6ZEhsc1pUMGlabWxzYkRvZ1lteGhZMnM3SUdadmJuUXRjMmw2WlRvZ016VndlRHNpUGlZak9UZ3hORHM4TDNSbGVIUStQSFJsZUhRZ2VEMGlOVEFsSWlCNVBTSXpNakFpSUhSbGVIUXRZVzVqYUc5eVBTSnRhV1JrYkdVaUlHTnNZWE56UFNKaVlYTmxJajVOZFhKd2FFeHBaMmgwUEM5MFpYaDBQangwWlhoMElIZzlJalV3SlNJZ2VUMGlNek0zSWlCMFpYaDBMV0Z1WTJodmNqMGliV2xrWkd4bElpQmpiR0Z6Y3owaVltRnpaU0krSTBNeFFqZEJNRHd2ZEdWNGRENDhjbVZqZENCNFBTSTFNQ0lnZVQwaU5UQWlJSGRwWkhSb1BTSXlOVEFpSUdobGFXZG9kRDBpTWpVd0lpQm1hV3hzUFNJalF6RkNOMEV3SWlBdlBqd3ZjM1puUGc9PSJ9";

    function getMappingValueStorageSlot(uint256 mappingKey, uint256 mappingVariableStorageSlot)
        public
        pure
        returns (bytes32 mappingValueStorageSlot)
    {
        mappingValueStorageSlot = keccak256(abi.encode(mappingKey, mappingVariableStorageSlot));
    }

    function convertStorageStringToColorNameString(bytes32 storageString)
        public
        pure
        returns (string memory nameString)
    {
        bytes memory storageStringBytes = abi.encode(storageString);
        uint256 sizeByte = uint8(storageStringBytes[31]);
        require(sizeByte % 2 == 0, "storage string too long");
        bytes memory nameStringBytes = new bytes(sizeByte / 2);
        for (uint256 i = 0; i < (sizeByte / 2); i++) {
            nameStringBytes[i] = storageStringBytes[i];
        }
        nameString = string(nameStringBytes);
    }

    function getColorNameFromStorage(address rocolorContract, uint256 _tokenId, uint256 mappingVariableStorageSlot)
        public
        view
        returns (string memory colorName)
    {
        // get the storage slot of the colorName
        bytes32 mappingValueStorageSlot = getMappingValueStorageSlot(_tokenId, mappingVariableStorageSlot);

        // get the value in that storage slot
        bytes32 storageValue = vm.load(rocolorContract, mappingValueStorageSlot);

        // get the colorName from that storage slot's value
        colorName = convertStorageStringToColorNameString(storageValue);
    }

    function convertStorageStringToColorOwnerAddress(bytes32 storageString) public pure returns (address ownerAddress) {
        bytes memory storageStringBytes = abi.encode(storageString);
        bytes memory ownerAddressBytes = new bytes(20);
        for (uint256 i = 0; i < 20; i++) {
            ownerAddressBytes[i] = storageStringBytes[12 + i];
        }
        ownerAddress = vm.parseAddress(vm.toString(ownerAddressBytes));
    }

    function getColorOwnerFromStorage(address rocolorContract, uint256 _tokenId, uint256 mappingVariableStorageSlot)
        public
        view
        returns (address colorOwner)
    {
        // get the storage slot of the colorOwner
        bytes32 mappingValueStorageSlot = getMappingValueStorageSlot(_tokenId, mappingVariableStorageSlot);

        // get the value in that storage slot
        bytes32 storageValue = vm.load(rocolorContract, mappingValueStorageSlot);

        // get the colorOwner from that storage slot's value
        colorOwner = convertStorageStringToColorOwnerAddress(storageValue);
    }
}
