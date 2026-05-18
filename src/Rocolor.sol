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
    bytes16 private constant HEX_SYMBOLS = "0123456789ABCDEF";
    uint256 private constant NUMBER_OF_BITS_IN_A_HEXADECIMAL = 4;

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
    error ROColor__DecimalTooBig(uint256 decimal);

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
     * @notice Converts a hexadecimal number into its decimal representation
     * @dev Constructs decimal number as the sum of the appropriately bit-shifted bit-values of each hexadecimal numeral
     * @dev Reverts if input is not exactly 6 bytes
     * @dev Reverts if an input byte is not a hexadecimal numeral
     * @param colorhex A hexadecimal number, likely a web color hex triplet
     * @return decimal A decimal number, likely a ROColor's tokenId
     */
    function convertColorhexToDecimal(string calldata colorhex) public pure returns (uint256 decimal) {
        bytes calldata colorhexBytes = bytes(colorhex);
        if (colorhexBytes.length != COLORHEX_VALID_LENGTH) revert ROColor__ColorhexLengthInvalid(colorhex);
        for (uint256 i; i < COLORHEX_VALID_LENGTH;) {
            bytes1 colorhexByte = colorhexBytes[(COLORHEX_VALID_LENGTH - 1) - i];
            uint256 a = uint8(colorhexByte); // rename 'a' to 'asciiNumber'? also, the casts seem awkward
            unchecked {
                // ASCII ranges: 0-9 (48-57), A-F (65-70), a-f (97-102)
                if (a > 47 && a < 58) {
                    decimal += (a - 48) << (NUMBER_OF_BITS_IN_A_HEXADECIMAL * i);
                } else if (a > 64 && a < 71) {
                    decimal += (a - 55) << (NUMBER_OF_BITS_IN_A_HEXADECIMAL * i);
                } else if (a > 96 && a < 103) {
                    decimal += (a - 87) << (NUMBER_OF_BITS_IN_A_HEXADECIMAL * i);
                } else {
                    revert ROColor__ColorhexCharacterInvalid(colorhexByte);
                }
                ++i;
            }
        }
    }

    /**
     * @notice Converts a decimal number into its hexadecimal representation
     * @dev Constructs hex triplet's bytes, right-to-left, with decimal's mod-16 value, then right-bit-shifting the decimal by 1 byte
     * @dev Reverts if input is 2^24 or greater
     * @param decimal A positive decimal integer, likely a ROColor's tokenId
     * @return colorhex A hexadecimal number, likely a web color hex triplet
     */
    function convertDecimalToColorhex(uint256 decimal) public pure returns (string memory colorhex) {
        if (decimal > 16777215) revert ROColor__DecimalTooBig(decimal);
        bytes memory colorhexBytes = new bytes(COLORHEX_VALID_LENGTH);
        for (uint256 i = 1; i < (COLORHEX_VALID_LENGTH + 1);) {
            colorhexBytes[COLORHEX_VALID_LENGTH - i] = HEX_SYMBOLS[decimal & 0xF];
            decimal >>= NUMBER_OF_BITS_IN_A_HEXADECIMAL;
            unchecked {
                ++i;
            }
        }
        colorhex = string(colorhexBytes);
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

// commenting pre-function, start w/ natspec:
// @notice explains to a user starting w/ present tense verb
// @dev explains to a developer, incl. requirements, important, warning, "emits an XYZ event", "reverts if..."
// @param
// @return
//
// commenting mid-function:
// notable subtitles within an important f'n
