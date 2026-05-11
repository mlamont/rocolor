// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

contract Rocolor {
    // this is it!

    /// @dev Custom string per unique tokenId, which can appear in the NFT pic.
    // mapping(uint => string) private _names;
    string private _name;

    function setName(string memory name) public {
        _name = name;
    }

    function getName() public view returns (string memory) {
        return _name;
    }

    constructor() {
        // starting stuff
    }
}
