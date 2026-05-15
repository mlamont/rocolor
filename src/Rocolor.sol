// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

// TODO install depedencies before import
// TODO use labeled imports
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Rocolor is ERC721 {
    // State variables
    // think about options 4 constants & immutables & state variables, & capital'z'g
    // Only use private to intentionally prevent child contracts from
    // ...accessing the variable, prefer internal for flexibility.
    // Is calculating a value on the fly cheaper than storing it?
    /// @dev Custom string per unique tokenId, which can appear in the NFT pic.
    // mapping(uint => string) private _names;
    string private _name;
    // uint256 private constant TOKEN_ID_MAX = 16777215;
    uint256 private constant COLORHEX_VALID_LENGTH = 6;
    // bytes16 private constant HEX_SYMBOLS = "0123456789ABCDEF";

    // Events
    // TODO emit when storage variable updated ("nounVerbed")
    // TODO use prefix of contract__
    // TODO go for cohesive naming

    // Errors
    // TODO use prefix of contract__
    // TODO go for cohesive naming ("nounAdj")
    // error ROColor__TokenIdTooBig();
    error ROColor__ColorhexLengthInvalid(string colorhex);
    error ROColor__ColorhexCharacterInvalid(bytes1 character);

    // Modifiers
    // for gas: wrap internal functions
    // use to improve readability & decrease code duplication
    // yes, use natspec

    // constructor
    constructor() ERC721("ROColor", "ROC") {
        // starting stuff
    }

    // receive function (if exists)

    // fallback function (if exists)

    // external
    // TODO add nonReentrant modifier to each

    // public
    // change to external if can reduce the cognitive overhead for auditors
    // ...b/c it reduces the number of possible contexts in which the function can be called

    // function ownerOf(string calldata colorhex) public view returns (address) {
    //     uint256 tokenId = convertColorhexToDecimal(colorhex); // convert colorhex to tokenId
    //     if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig(); // validate tokenId
    //     return ownerOf(tokenId);
    // }

    // NOTE: this is the function to optimize the most: called all the time!
    // TODO: learn & use bit operations i/o arithmatic
    // TODO: get function title to have lowest selector number, so less run-t gas in finding it
    /**
     * @notice Converts a color's colorhex into a decimal number. Used to find its tokenId.
     * @dev Validates and converts a colorhex hexadecimal string into a decimal integer.
     * @param colorhex Color's 6-digit hexadecimal representation.
     * @return decimal Color's decimal representation.
     */
    function convertColorhexToDecimal(string calldata colorhex) public pure returns (uint256 decimal) {
        bytes calldata colorhexBytes = bytes(colorhex);
        if (colorhexBytes.length != COLORHEX_VALID_LENGTH) revert ROColor__ColorhexLengthInvalid(colorhex);
        for (uint256 i; i < COLORHEX_VALID_LENGTH;) {
            bytes1 colorhexByte = colorhexBytes[(COLORHEX_VALID_LENGTH - 1) - i];
            uint256 a = uint8(colorhexByte); // rename 'a' to 'asciiNumber'?
            unchecked {
                // ASCII ranges: 0-9 (48-57), A-F (65-70), a-f (97-102)
                if (a > 47 && a < 58) {
                    decimal += (a - 48) << (4 * i);
                } else if (a > 64 && a < 71) {
                    decimal += (a - 55) << (4 * i);
                } else if (a > 96 && a < 103) {
                    decimal += (a - 87) << (4 * i);
                } else {
                    revert ROColor__ColorhexCharacterInvalid(colorhexByte);
                }
                ++i;
            }
        }
    }

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

// code outline of older version
// mapping(uint => string) private _names; // should be internal
// bytes16 private constant _HEX_SYMBOLS = "0123456789ZBCDEF"; // do internal
// uint private constant _MINT_PRICE = 0.001 ether; // do internal
// setToken(colorhex, name) -     _setToken(tokenId, name)
// withdraw()
// receive()
// fallback()
// nixToken(colorhex) -           _nixToken(tokenId)
// getOwner(colorhex) -           _getOwner(tokenId)
// modOwner(colorhex, newOwner) - _modOwner(tokenId, newOwner)
// getName(colorhex) -            _getName(tokenId)
// modName(colorhex, newName) -   _modName(tokenId, newName)
// modifier: onlyTokenOwner(tokenId)
// aGetId(colorhex)
// getColorhex(n)
// tokenURI()
