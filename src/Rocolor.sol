// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

// TODO install depedencies before import
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract Rocolor is ERC721, Ownable {
    /****
    ***** STATE VARIABLES
    ****/

    // think about options 4 constants & immutables & state variables, & capital'z'g
    // Only use private to intentionally prevent child contracts from
    // ...accessing the variable, prefer internal for flexibility.
    // Is calculating a value on the fly cheaper than storing it?
    mapping(uint256 tokenId => string) internal _colorNames; // include "tokenId"? internal i/o private?
    uint256 private constant TOKEN_ID_MAX = 16777215;
    uint256 private constant HEX_TRIPLET_VALID_LENGTH = 6;
    bytes16 private constant HEX_SYMBOLS = "0123456789ABCDEF";
    uint256 private constant NUMBER_OF_BITS_IN_A_HEXADECIMAL = 4;
    string private constant _SVG_PART_1 =
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="50%" y="16" text-anchor="middle" rotate="180" style="fill: black; font-size: 35px;">&#9814;</text><text x="50%" y="320" text-anchor="middle" class="base">';
    string private constant _SVG_PART_2 = '</text><text x="50%" y="337" text-anchor="middle" class="base">#';
    string private constant _SVG_PART_3 = '</text><rect x="50" y="50" width="250" height="250" fill="#';
    string private constant _SVG_PART_4 = '" /></svg>';

    /****
    ***** EVENTS
    ****/

    // TODO emit when storage variable updated ("nounVerbed")
    // TODO go for cohesive naming

    event ROColor__DepositReceived(address sender, uint256 amount);
    event ROColor__Rename(string from, string to, uint256 tokenId);
    event ROColor__ContractBalanceWithdrawalPassed(uint256 contractBalance);

    /****
    ***** ERRORS
    ****/

    // TODO go for cohesive naming ("nounAdj")
    error ROColor__TokenIdTooBig();
    error ROColor__HexTripletLengthInvalid(string hexTriplet);
    error ROColor__HexTripletNumeralInvalid(bytes1 numeral);
    error ROColor__DecimalTooBig(uint256 decimal);
    error ROColor__ContractBalanceWithdrawalFailed();
    error ROColor__ContractBalanceEmpty();

    /****
    ***** MODIFIERS
    ****/

    // for gas: wrap internal functions
    // use to improve readability & decrease code duplication
    // yes, use natspec

    /****
    ***** CONSTRUCTOR
    ****/

    constructor() ERC721("ROColor", "ROC") Ownable(_msgSender()) {
        // starting stuff
    }

    /****
    ***** RECEIVE FUNCTION
    ****/

    /**
     * @notice Receives funds
     * @dev Emits a ROColor__DepositReceived event
     */
    receive() external payable {
        emit ROColor__DepositReceived(_msgSender(), msg.value);
    }

    /****
    ***** FALLBACK FUNCTION
    ****/

    /**
     * @notice Receives funds
     * @dev Emits a ROColor__DepositReceived event
     */
    fallback() external payable {
        emit ROColor__DepositReceived(_msgSender(), msg.value);
    }

    /****
    ***** EXTERNAL FUNCTIONS
    ****/

    // TODO add nonReentrant modifier to each
    // ...REALLY?

    /**
     * @notice Withdraws all funds from the contract, only by the contract owner
     * @dev Reverts if contract is owned by someone else
     * @dev Reverts if contract has no funds to withdraw
     * @dev Reverts if fund withdrawal failed
     * @dev Emits a ROColor__ContractBalanceWithdrawalPassed event
     */
    function withdraw() external onlyOwner {
        // gotta ensure the checks-effects-interactions pattern is always in here
        uint256 balanceOfThisContract = address(this).balance;
        if (balanceOfThisContract == 0) revert ROColor__ContractBalanceEmpty();
        // call() doesn't require owner() wrapped in payable()
        (bool success,) = owner().call{value: balanceOfThisContract}("");
        if (!success) revert ROColor__ContractBalanceWithdrawalFailed();
        emit ROColor__ContractBalanceWithdrawalPassed(balanceOfThisContract);
    }

    /**
     * @notice Creates a ROColor named color token
     * @dev Converts hex triplet to tokenId, validates it, then passes to internal function
     * @dev Reverts if hex triplet is not exactly 6 bytes
     * @dev Reverts if a hex triplet byte is not a hexadecimal numeral
     * @dev Reverts if minting to the burn address
     * @dev Reverts if token already exists
     * @dev Emits a Transfer event
     * @dev Emits a ROColor__Rename event
     * @param hexTriplet Hex triplet of the ROColor
     * @param colorName Name of the ROColor
     */
    function mintColor(string calldata hexTriplet, string calldata colorName) external {
        uint256 tokenId = convertHexTripletToDecimal(hexTriplet);
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig();
        _mintColor(tokenId, colorName);
    }

    /**
     * @notice Changes the name of a ROColor token
     * @dev Converts hex triplet to tokenId, validates it, then passes to internal function
     * @dev Reverts if hex triplet is not exactly 6 bytes
     * @dev Reverts if a hex triplet byte is not a hexadecimal numeral
     * @dev Reverts if token is not currently owned/minted
     * @dev Reverts if token is owned by someone else
     * @dev Emits a ROColor__Rename event
     * @param hexTriplet Hex triplet of the ROColor
     * @param newColorName Name of the ROColor
     */
    function changeColorName(string calldata hexTriplet, string calldata newColorName) external {
        uint256 tokenId = convertHexTripletToDecimal(hexTriplet);
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig();
        _allowOnlyColorOwner(tokenId);
        _changeColorName(tokenId, newColorName);
    }

    /**
     * @notice Changes the owner of a ROColor token
     * @dev Converts hex triplet to tokenId, validates it, then passes to internal function
     * @dev Reverts if hex triplet is not exactly 6 bytes
     * @dev Reverts if a hex triplet byte is not a hexadecimal numeral
     * @dev Reverts if transfering to the burn address
     * @dev Reverts if token is not currently owned/minted
     * @dev Reverts if token is owned by someone else
     * @dev Emits a Transfer event
     * @param hexTriplet Hex triplet of the ROColor
     * @param newColorOwner Owner of the ROColor
     */
    function changeColorOwner(string calldata hexTriplet, address newColorOwner) external {
        uint256 tokenId = convertHexTripletToDecimal(hexTriplet);
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig();
        _changeColorOwner(tokenId, newColorOwner);
    }

    /**
     * @notice Destroys a ROColor named color token
     * @dev Converts hex triplet to tokenId, validates it, then passes to internal function
     * @dev Reverts if hex triplet is not exactly 6 bytes
     * @dev Reverts if a hex triplet byte is not a hexadecimal numeral
     * @dev Reverts if token is not currently owned/minted
     * @dev Reverts if token is owned by someone else
     * @dev Emits a Transfer event
     * @dev Emits a ROColor__Rename event
     * @param hexTriplet Hex triplet of the ROColor
     */
    function burnColor(string calldata hexTriplet) external {
        uint256 tokenId = convertHexTripletToDecimal(hexTriplet);
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig();
        _allowOnlyColorOwner(tokenId);
        _burnColor(tokenId);
    }

    /**
     * @notice Gets the name of a ROColor token
     * @dev Converts hex triplet to tokenId, validates it, then passes to internal function
     * @dev Reverts if hex triplet is not exactly 6 bytes
     * @dev Reverts if a hex triplet byte is not a hexadecimal numeral
     * @param hexTriplet Hex triplet of the ROColor
     */
    function getColorName(string calldata hexTriplet) external view returns (string memory) {
        uint256 tokenId = convertHexTripletToDecimal(hexTriplet);
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig();
        return _getColorName(tokenId);
    }

    /**
     * @notice Gets the owner of a ROColor token
     * @dev Converts hex triplet to tokenId, validates it, then passes to internal function
     * @dev Reverts if hex triplet is not exactly 6 bytes
     * @dev Reverts if a hex triplet byte is not a hexadecimal numeral
     * @dev Reverts if token is not currently owned/minted
     * @param hexTriplet Hex triplet of the ROColor
     */
    function getColorOwner(string calldata hexTriplet) external view returns (address) {
        uint256 tokenId = convertHexTripletToDecimal(hexTriplet);
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig();
        return _getColorOwner(tokenId);
    }

    /****
    ***** PUBLIC FUNCTIONS
    ****/

    // change to external if can reduce the cognitive overhead for auditors
    // ...b/c it reduces the number of possible contexts in which the function can be called

    // NOTE: this is the function to optimize the most: called all the time!
    // TODO: learn & use bit operations i/o arithmatic
    // TODO: get function title to have lowest selector number, so less run-t gas in finding it
    /**
     * @notice Converts a hexadecimal number into its decimal representation
     * @dev Constructs decimal number as the sum of the appropriately bit-shifted bit-values of each hexadecimal numeral
     * @dev Reverts if input is not exactly 6 bytes
     * @dev Reverts if an input byte is not a hexadecimal numeral
     * @param hexTriplet A hexadecimal number, likely a web color hex triplet
     * @return decimal A decimal number, likely a ROColor's tokenId
     */
    function convertHexTripletToDecimal(string calldata hexTriplet) public pure returns (uint256 decimal) {
        bytes calldata hexTripletBytes = bytes(hexTriplet);
        if (hexTripletBytes.length != HEX_TRIPLET_VALID_LENGTH) revert ROColor__HexTripletLengthInvalid(hexTriplet);
        for (uint256 i; i < HEX_TRIPLET_VALID_LENGTH;) {
            bytes1 hexTripletByte = hexTripletBytes[(HEX_TRIPLET_VALID_LENGTH - 1) - i];
            uint256 a = uint8(hexTripletByte); // rename 'a' to 'asciiNumber'? also, the casts seem awkward
            unchecked {
                // ASCII ranges: 0-9 (48-57), A-F (65-70), a-f (97-102)
                if (a > 47 && a < 58) {
                    decimal += (a - 48) << (NUMBER_OF_BITS_IN_A_HEXADECIMAL * i);
                } else if (a > 64 && a < 71) {
                    decimal += (a - 55) << (NUMBER_OF_BITS_IN_A_HEXADECIMAL * i);
                } else if (a > 96 && a < 103) {
                    decimal += (a - 87) << (NUMBER_OF_BITS_IN_A_HEXADECIMAL * i);
                } else {
                    revert ROColor__HexTripletNumeralInvalid(hexTripletByte);
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
     * @return hexTriplet A hexadecimal number, likely a web color hex triplet
     */
    function convertDecimalToHexTriplet(uint256 decimal) public pure returns (string memory hexTriplet) {
        if (decimal > TOKEN_ID_MAX) revert ROColor__DecimalTooBig(decimal);
        bytes memory hexTripletBytes = new bytes(HEX_TRIPLET_VALID_LENGTH);
        for (uint256 i = 1; i < (HEX_TRIPLET_VALID_LENGTH + 1);) {
            hexTripletBytes[HEX_TRIPLET_VALID_LENGTH - i] = HEX_SYMBOLS[decimal & 0xF];
            decimal >>= NUMBER_OF_BITS_IN_A_HEXADECIMAL;
            unchecked {
                ++i;
            }
        }
        hexTriplet = string(hexTripletBytes);
    }

    /**
     * @notice Gets the tokenURI, with SVG picture, of a ROColor token
     * @dev Constructs, packs, and Base64-encodes the metadata associated with a tokenId
     * @dev Reverts if input is 2^24 or greater
     * @param tokenId Token ID of the ROColor
     * @return tokenUri Token URI, with SVG picture, of the ROColor
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory tokenUri) {
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig();
        string memory colorName = _getColorName(tokenId);
        string memory hexTriplet = convertDecimalToHexTriplet(tokenId);

        // Pack SVG parts directly into bytes
        bytes memory svgBytes =
            abi.encodePacked(_SVG_PART_1, colorName, _SVG_PART_2, hexTriplet, _SVG_PART_3, hexTriplet, _SVG_PART_4);

        // Base64 encode the SVG bytes
        string memory encodedSvg = Base64.encode(svgBytes);

        // Create and encode the JSON directly
        bytes memory jsonBytes = abi.encodePacked(
            '{"name": "',
            colorName,
            '", "description": "a ROColor for onchain art", "image": ',
            '"data:image/svg+xml;base64,',
            encodedSvg,
            '"}'
        );

        // Base64 encode the JSON and create the final URI
        tokenUri = string(abi.encodePacked("data:application/json;base64,", Base64.encode(jsonBytes)));
    }

    /****
    ***** INTERNAL FUNCTIONS
    ****/

    /**
     * @notice Creates a ROColor named color token
     * @dev No input validations beyond ERC721 base contract token-minting validations
     * @dev Reverts if minting to the burn address
     * @dev Reverts if token already exists
     * @dev Emits a Transfer event
     * @dev Emits a ROColor__Rename event
     * @param tokenId Token ID of the ROColor
     * @param colorName Name of the ROColor
     */
    function _mintColor(uint256 tokenId, string memory colorName) internal {
        _safeMint(_msgSender(), tokenId);
        _changeColorName(tokenId, colorName);
    }

    /**
     * @notice Changes the name of a ROColor token
     * @dev No input validations
     * @dev Emits a ROColor__Rename event
     * @param tokenId Token ID of the ROColor
     * @param newColorName Name of the ROColor
     */
    function _changeColorName(uint256 tokenId, string memory newColorName) internal {
        string memory oldColorName = _colorNames[tokenId];
        _colorNames[tokenId] = newColorName;
        emit ROColor__Rename(oldColorName, newColorName, tokenId);
    }

    /**
     * @notice Changes the owner of a ROColor token
     * @dev No input validations beyond ERC721 base contract token-transfering validations
     * @dev Reverts if transfering to the burn address
     * @dev Reverts if token is not currently owned/minted
     * @dev Reverts if token is owned by someone else
     * @dev Emits a Transfer event
     * @param tokenId Token ID of the ROColor
     * @param newColorOwner Owner of the ROColor
     */
    function _changeColorOwner(uint256 tokenId, address newColorOwner) internal {
        _safeTransfer(_msgSender(), newColorOwner, tokenId);
    }

    /**
     * @notice Destroys a ROColor named color token
     * @dev No input validations beyond ERC721 base contract token-burning validations
     * @dev Reverts if token is not currently owned/minted
     * @dev Emits a Transfer event
     * @dev Emits a ROColor__Rename event
     * @param tokenId Token ID of the ROColor
     */
    function _burnColor(uint256 tokenId) internal {
        _changeColorName(tokenId, "");
        _burn(tokenId);
    }

    /**
     * @notice Gets the name of a ROColor token
     * @dev No input validations
     * @param tokenId Token ID of the ROColor
     */
    function _getColorName(uint256 tokenId) internal view returns (string memory) {
        return _colorNames[tokenId];
    }

    /**
     * @notice Gets the owner of a ROColor token
     * @dev No input validations beyond ERC721 base contract token-owner-getting validations
     * @dev Reverts if token is not currently owned/minted
     * @param tokenId Token ID of the ROColor
     */
    function _getColorOwner(uint256 tokenId) internal view returns (address) {
        return ownerOf(tokenId);
    }

    /**
     * @notice Allows only the owner of a ROColor token to continue
     * @dev No input validations beyond ERC721 base contract token-owner-getting validations
     * @dev Reverts if token is not currently owned/minted
     * @dev Reverts if token is owned by someone else
     * @param tokenId Token ID of the ROColor
     */
    function _allowOnlyColorOwner(uint256 tokenId) internal view {
        address colorOwner = _requireOwned(tokenId);
        if (colorOwner != _msgSender()) revert ERC721IncorrectOwner(_msgSender(), tokenId, colorOwner);
    }

    /****
    ***** PRIVATE FUNCTIONS
    ****/

    // Only use private to intentionally prevent child contracts from
    // ...calling the function, prefer internal for flexibility.

    // within each: view & pure f'n.s last
}

// code outline of newer version
/* mapping(uint256 => string) internal _colorNames; */
/*                                               _allowOnlyColorOwner(tokenId) */
/* receive() */
/* fallback() */
/* withdraw() */
/* mintColor(hexTriplet, colorName)              _mintColor(tokenId, colorName) */
/* burnColor(hexTriplet)                         _burnColor(tokenId) */
/* getColorOwner(hexTriplet)                     _getColorOwner(tokenId) */
/* changeColorOwner(hexTriplet, newColorOwner)   _changeColorOwner(tokenId, newColorOwner) */
/* getColorName(hexTriplet)                      _getColorName(tokenId) */
/* changeColorName(hexTriplet, newColorName)     _changeColorName(tokenId, newColorName) */
/* convertDecimalToHexTriplet(decimal) */
/* convertHexTripletToDecimal(hexTriplet) */
/* tokenURI() */
// ... TODO: NAMING: name functions like this: [verb: mint/burn, get/change]Color[aspect: owner/name], which'll always take a 'hexTriplet' param
// ... TODO: SCOPE: only 1 task per 1 function, so embrace the smaller scope of activity, reflected in function name
// ... TODO: DOC: put in NatSpec: where internal functions are unchecked (checks are in the external functions), beyond what ERC721 does
// ... TODO: SECURITY: CEI-PI / fn

// code outline of older version
// mapping(uint => string) private _names; // should be internal
// bytes16 private constant _HEX_SYMBOLS = "0123456789ZBCDEF"; // do internal
// uint private constant _MINT_PRICE = 0.001 ether; // do internal
// setToken(colorhex, name) -     _setToken(tokenId, name)
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
