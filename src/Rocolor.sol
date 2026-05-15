// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

// TODO install depedencies before import
// TODO use labeled imports

contract Rocolor {
    // State variables
    // think about options 4 constants & immutables & state variables, & capital'z'g
    // Only use private to intentionally prevent child contracts from
    // ...accessing the variable, prefer internal for flexibility.
    // Is calculating a value on the fly cheaper than storing it?
    /// @dev Custom string per unique tokenId, which can appear in the NFT pic.
    // mapping(uint => string) private _names;
    string private _name;

    // Events
    // TODO emit when storage variable updated ("nounVerbed")
    // TODO use prefix of contract__
    // TODO go for cohesive naming

    // Errors
    // TODO use prefix of contract__
    // TODO go for cohesive naming

    // Modifiers
    // for gas: wrap internal functions
    // use to improve readability & decrease code duplication
    // yes, use natspec

    // constructor
    constructor() {
        // starting stuff
    }

    // receive function (if exists)

    // fallback function (if exists)

    // external
    // TODO add nonReentrant modifier to each

    // public
    // change to external if can reduce the cognitive overhead for auditors
    // ...b/c it reduces the number of possible contexts in which the function can be called

    // internal

    // private
    // Only use private to intentionally prevent child contracts from
    // ...calling the function, prefer internal for flexibility.

    // within each: view & pure f'n.s last

    function setName(string memory name) public {
        _name = name;
    }

    function getName() public view returns (string memory) {
        return _name;
    }
}

// code outline
// mapping(uint => string) private _names; // should be internal
// bytes16 private constant _HEX_SYMBOLS = "0123456789ZBCDEF"; // do internal
// uint private constant _MINT_PRICE = 0.001 ether; // do internal
// setToken(colorhex, name)
// _setToken(tokenId, name)
// withdraw()
// receive()
// fallback()
// nixToken(colorhex)
// _nixToken(tokenId)
// getOwner(colorhex)
// _getOwner(tokenId)
// modOwner(colorhex, newOwner)
// _modOwner(tokenId, newOwner)
// getName(colorhex)
// _getName(tokenId)
// modName(colorhex, newName)
// _modName(tokenId, newName)
// modifier: onlyTokenOwner(tokenId)
// aGetId(colorhex)
// getColorhex(n)
// tokenURI()
