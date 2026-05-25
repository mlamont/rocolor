// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {Test} from "lib/forge-std/src/Test.sol";

contract RocolorTestHelpers is Test {
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
        // ownerAddress = string(nameStringBytes);

        // how are addresses stored in a storage slot?
        // ownerAddress = address(uint160(abi.encode(storageString)));
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
