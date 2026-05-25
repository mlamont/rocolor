// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title ROColor
 * @author Merrill B. Lamont III (rockopera.eth)
 * @notice Tokenizes the 16M+ web colors into nameable, collectible, and usable native-onchain assets
 * @dev ERC721 NFT contract is intended to compose with similar native-onchain art tech, resulting in fully-onchain artwork
 */
contract Rocolor is ERC721, Ownable, ReentrancyGuard {
    /****
    ***** STATE VARIABLES
    ****/

    // DONE include "tokenId"?
    mapping(uint256 tokenId => string colorName) internal _colorNames;

    uint256 private constant TOKEN_ID_MAX = 16777215;
    uint256 private constant HEX_TRIPLET_VALID_LENGTH = 6;
    uint256 private constant COLOR_NAME_MAX_LENGTH = 31;
    bytes16 private constant HEX_SYMBOLS = "0123456789ABCDEF";
    uint256 private constant NUMBER_OF_BITS_IN_A_HEXADECIMAL = 4;
    uint256 private constant COLOR_PRICE_MIN = 0.001 ether;
    string private constant _SVG_PART_1 =
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="50%" y="16" text-anchor="middle" rotate="180" style="fill: black; font-size: 35px;">&#9814;</text><text x="50%" y="320" text-anchor="middle" class="base">';
    string private constant _SVG_PART_2 = '</text><text x="50%" y="337" text-anchor="middle" class="base">#';
    string private constant _SVG_PART_3 = '</text><rect x="50" y="50" width="250" height="250" fill="#';
    string private constant _SVG_PART_4 = '" /></svg>';

    /****
    ***** EVENTS
    ****/

    event ROColor__DepositReceived(address indexed sender, uint256 indexed amount);
    event ROColor__Rename(string indexed from, string indexed to, uint256 indexed tokenId);
    event ROColor__ContractBalanceWithdrawalPassed(uint256 indexed contractBalance);

    /****
    ***** ERRORS
    ****/

    error ROColor__TokenIdTooBig(uint256 tokenId);
    error ROColor__HexTripletLengthInvalid(string hexTriplet);
    error ROColor__HexTripletNumeralInvalid(bytes1 numeral);
    error ROColor__ColorNameTooBig(string colorName);
    error ROColor__FundsInsufficient();
    error ROColor__ContractBalanceWithdrawalFailed();
    error ROColor__ContractBalanceEmpty();

    /****
    ***** CONSTRUCTOR
    ****/

    // DONE nothing in here?
    constructor() ERC721("ROColor", "ROC") Ownable(_msgSender()) {}

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

    // DONE deep review of each line, and put a REENTRANCY guard here
    /**
     * @notice Withdraws all funds from the contract, only by the contract owner
     * @dev Reverts if contract is owned by someone else
     * @dev Reverts if contract has no funds to withdraw
     * @dev Reverts if fund withdrawal failed
     * @dev Emits a ROColor__ContractBalanceWithdrawalPassed event
     */
    function withdraw() external onlyOwner nonReentrant {
        // gotta ensure the checks-effects-interactions pattern is always in here
        uint256 balanceOfThisContract = address(this).balance;
        if (balanceOfThisContract == 0) revert ROColor__ContractBalanceEmpty();
        (bool success,) = payable(owner()).call{value: balanceOfThisContract}("");
        if (!success) revert ROColor__ContractBalanceWithdrawalFailed();
        emit ROColor__ContractBalanceWithdrawalPassed(balanceOfThisContract);
        if (address(this).balance != 0) revert ROColor__ContractBalanceWithdrawalFailed();
    }

    /**
     * @notice Creates a ROColor named color token
     * @dev Converts hex triplet to tokenId, does checks, then passes to internal function
     * @dev Reverts if hex triplet is not exactly 6 bytes
     * @dev Reverts if a hex triplet byte is not a hexadecimal numeral
     * @dev Reverts if calculated tokenId is 2^24 or greater
     * @dev Reverts if name length is over 31 bytes
     * @dev Reverts if funds are less than the price of the color token
     * @dev Reverts if minting to the burn address
     * @dev Reverts if token already exists
     * @dev Emits a Transfer event
     * @dev Emits a ROColor__Rename event
     * @param hexTriplet Hex triplet of the ROColor
     * @param colorName Name of the ROColor
     */
    function mintColor(string calldata hexTriplet, string calldata colorName) external payable nonReentrant {
        if (bytes(colorName).length > COLOR_NAME_MAX_LENGTH) revert ROColor__ColorNameTooBig(colorName); // cheap checks first
        uint256 tokenId = convertHexTripletToDecimal(hexTriplet);
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig(tokenId);
        if (msg.value < _getColorPrice(tokenId)) revert ROColor__FundsInsufficient();
        _mintColor(tokenId, colorName);
    }

    /**
     * @notice Changes the name of a ROColor token
     * @dev Converts hex triplet to tokenId, does checks, then passes to internal function
     * @dev Reverts if hex triplet is not exactly 6 bytes
     * @dev Reverts if a hex triplet byte is not a hexadecimal numeral
     * @dev Reverts if calculated tokenId is 2^24 or greater
     * @dev Reverts if name length is over 31 bytes
     * @dev Reverts if token is not currently owned/minted
     * @dev Reverts if token is owned by someone else
     * @dev Emits a ROColor__Rename event
     * @param hexTriplet Hex triplet of the ROColor
     * @param newColorName Name of the ROColor
     */
    function changeColorName(string calldata hexTriplet, string calldata newColorName) external {
        if (bytes(newColorName).length > COLOR_NAME_MAX_LENGTH) revert ROColor__ColorNameTooBig(newColorName); // cheap checks first
        uint256 tokenId = convertHexTripletToDecimal(hexTriplet);
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig(tokenId);
        _allowOnlyColorOwner(tokenId);
        _changeColorName(tokenId, newColorName);
    }

    /**
     * @notice Changes the owner of a ROColor token
     * @dev Converts hex triplet to tokenId, does checks, then passes to internal function
     * @dev Reverts if hex triplet is not exactly 6 bytes
     * @dev Reverts if a hex triplet byte is not a hexadecimal numeral
     * @dev Reverts if calculated tokenId is 2^24 or greater
     * @dev Reverts if transfering to the burn address
     * @dev Reverts if token is not currently owned/minted
     * @dev Reverts if token is owned by someone else
     * @dev Emits a Transfer event
     * @param hexTriplet Hex triplet of the ROColor
     * @param newColorOwner Owner of the ROColor
     */
    function changeColorOwner(string calldata hexTriplet, address newColorOwner) external {
        uint256 tokenId = convertHexTripletToDecimal(hexTriplet);
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig(tokenId);
        _changeColorOwner(tokenId, newColorOwner);
    }

    /**
     * @notice Destroys a ROColor named color token
     * @dev Converts hex triplet to tokenId, does checks, then passes to internal function
     * @dev Reverts if hex triplet is not exactly 6 bytes
     * @dev Reverts if a hex triplet byte is not a hexadecimal numeral
     * @dev Reverts if calculated tokenId is 2^24 or greater
     * @dev Reverts if token is not currently owned/minted
     * @dev Reverts if token is owned by someone else
     * @dev Emits a Transfer event
     * @dev Emits a ROColor__Rename event
     * @param hexTriplet Hex triplet of the ROColor
     */
    function burnColor(string calldata hexTriplet) external {
        uint256 tokenId = convertHexTripletToDecimal(hexTriplet);
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig(tokenId);
        _allowOnlyColorOwner(tokenId);
        _burnColor(tokenId);
    }

    /**
     * @notice Gets the name of a ROColor token
     * @dev Converts hex triplet to tokenId, does checks, then passes to internal function
     * @dev Reverts if hex triplet is not exactly 6 bytes
     * @dev Reverts if a hex triplet byte is not a hexadecimal numeral
     * @dev Reverts if calculated tokenId is 2^24 or greater
     * @param hexTriplet Hex triplet of the ROColor
     * @return colorName Name of the ROColor
     */
    function getColorName(string calldata hexTriplet) external view returns (string memory colorName) {
        uint256 tokenId = convertHexTripletToDecimal(hexTriplet);
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig(tokenId);
        colorName = _getColorName(tokenId);
    }

    /**
     * @notice Gets the owner of a ROColor token
     * @dev Converts hex triplet to tokenId, does checks, then passes to internal function
     * @dev Reverts if hex triplet is not exactly 6 bytes
     * @dev Reverts if a hex triplet byte is not a hexadecimal numeral
     * @dev Reverts if calculated tokenId is 2^24 or greater
     * @dev Reverts if token is not currently owned/minted
     * @param hexTriplet Hex triplet of the ROColor
     * @return colorOwner Owner of the ROColor
     */
    function getColorOwner(string calldata hexTriplet) external view returns (address colorOwner) {
        uint256 tokenId = convertHexTripletToDecimal(hexTriplet);
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig(tokenId);
        colorOwner = _getColorOwner(tokenId);
    }

    /**
     * @notice Gets the price of a ROColor token
     * @dev Converts hex triplet to tokenId, does checks, then passes to internal function
     * @dev Reverts if hex triplet is not exactly 6 bytes
     * @dev Reverts if a hex triplet byte is not a hexadecimal numeral
     * @dev Reverts if calculated tokenId is 2^24 or greater
     * @param hexTriplet Hex triplet of the ROColor
     * @return colorPrice Price of the ROColor
     */
    function getColorPrice(string calldata hexTriplet) external pure returns (uint256 colorPrice) {
        uint256 tokenId = convertHexTripletToDecimal(hexTriplet);
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig(tokenId);
        colorPrice = _getColorPrice(tokenId);
    }

    /****
    ***** PUBLIC FUNCTIONS
    ****/

    // NOTE: this is the function to optimize the most: called all the time!
    // DONE rename 'a' to 'asciiNumber'? also, the casts seem awkward
    // DONE: learn & use bit operations i/o arithmatic
    // DONE: get function title to have lowest selector number, so less run-t gas in finding it
    /**
     * @notice Converts a hexadecimal number into its decimal representation: a human-friendly color identifier to a contract-friendly one
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
            bytes1 asciiHex = hexTripletBytes[(HEX_TRIPLET_VALID_LENGTH - 1) - i];
            uint256 asciiDecimal = uint8(asciiHex);
            unchecked {
                // ASCII ranges: 0-9 (48-57), A-F (65-70), a-f (97-102)
                if (asciiDecimal > 47 && asciiDecimal < 58) {
                    decimal += (asciiDecimal - 48) << (NUMBER_OF_BITS_IN_A_HEXADECIMAL * i);
                } else if (asciiDecimal > 64 && asciiDecimal < 71) {
                    decimal += (asciiDecimal - 55) << (NUMBER_OF_BITS_IN_A_HEXADECIMAL * i);
                } else if (asciiDecimal > 96 && asciiDecimal < 103) {
                    decimal += (asciiDecimal - 87) << (NUMBER_OF_BITS_IN_A_HEXADECIMAL * i);
                } else {
                    revert ROColor__HexTripletNumeralInvalid(asciiHex);
                }
                ++i;
            }
        }
    }

    /**
     * @notice Converts a decimal number into its hexadecimal representation: a contract-friendly color identifier to a human-friendly one
     * @dev Constructs hex triplet's bytes, right-to-left, with decimal's mod-16 value, then right-bit-shifting the decimal by 1 byte
     * @dev Reverts if input is 2^24 or greater
     * @param decimal A positive decimal integer, likely a ROColor's tokenId
     * @return hexTriplet A hexadecimal number, likely a web color hex triplet
     */
    function convertDecimalToHexTriplet(uint256 decimal) public pure returns (string memory hexTriplet) {
        if (decimal > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig(decimal);
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
     * @notice Gets the tokenURI of a ROColor token: the picture and other metadata
     * @dev Constructs, packs, and Base64-encodes the metadata associated with a tokenId
     * @dev Reverts if input is 2^24 or greater
     * @param tokenId Token ID of the ROColor
     * @return tokenUri Token URI, with SVG picture, of the ROColor
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory tokenUri) {
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig(tokenId);
        string memory colorName = _getColorName(tokenId);
        string memory hexTriplet = convertDecimalToHexTriplet(tokenId);
        bytes memory svgBytes =
            abi.encodePacked(_SVG_PART_1, colorName, _SVG_PART_2, hexTriplet, _SVG_PART_3, hexTriplet, _SVG_PART_4);
        string memory encodedSvg = Base64.encode(svgBytes);
        bytes memory jsonBytes = abi.encodePacked(
            '{"name": "',
            colorName,
            '", "description": "a ROColor for onchain art", "image": ',
            '"data:image/svg+xml;base64,',
            encodedSvg,
            '"}'
        );
        tokenUri = string(abi.encodePacked("data:application/json;base64,", Base64.encode(jsonBytes)));
    }

    /****
    ***** INTERNAL FUNCTIONS
    ****/

    // DONE make this payable?
    // DONE: learn & use: bit operations & bitmaps to reduce comparisons, and punt price check to end
    // DONE: investigate WARNING: minting is a source of reentrancy: it calls IERC721Receiver(to).onERC721received(): YES! put a reentrancy guard in the external version
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
     * @dev Does not revert if token is not currently owned/minted
     * @param tokenId Token ID of the ROColor
     * @return colorName Name of the ROColor
     */
    function _getColorName(uint256 tokenId) internal view returns (string memory colorName) {
        colorName = _colorNames[tokenId];
    }

    /**
     * @notice Gets the owner of a ROColor token
     * @dev No input validations beyond ERC721 base contract token-owner-getting validations
     * @dev Reverts if token is not currently owned/minted
     * @param tokenId Token ID of the ROColor
     * @return colorOwner Owner of the ROColor
     */
    function _getColorOwner(uint256 tokenId) internal view returns (address colorOwner) {
        colorOwner = ownerOf(tokenId);
    }

    // DONE comment to include color names w/ tokenIds
    // DONE learn & use: bit operations & bitmaps to reduce comparisons
    // DONE if & elseif instead of 2 separate ifs
    // DONE investigate if can say token IS IN {255, 65280, ...}
    // DONE consider unchecked {}
    /**
     * @notice Gets the price of a ROColor token
     * @dev Constructs price as the product of a minimum and a factor representing pricing tiers
     * @param tokenId Token ID of the ROColor
     * @return colorPrice Price of the ROColor
     */
    function _getColorPrice(uint256 tokenId) internal pure returns (uint256 colorPrice) {
        // 0.001 ETH for all web colors, unless it's the below
        uint256 colorPriceMultiplier = 1;
        if (tokenId == 0 || tokenId == TOKEN_ID_MAX) {
            // 10 ETH for black, white
            colorPriceMultiplier = 10000;
        } else if (
            tokenId == 0x0000FF || tokenId == 0x00FF00 || tokenId == 0xFF0000 || tokenId == 0x00FFFF
                || tokenId == 0xFF00FF || tokenId == 0xFFFF00
        ) {
            // 1 ETH for blue, green, red, cyan, magenta, yellow
            colorPriceMultiplier = 1000;
        }
        colorPrice = COLOR_PRICE_MIN * colorPriceMultiplier;
    }

    /**
     * @notice Allows only the owner of a ROColor token to continue: access-control for certain actions
     * @dev No input validations beyond ERC721 base contract token-owner-getting validations
     * @dev Reverts if token is not currently owned/minted
     * @dev Reverts if token is owned by someone else
     * @param tokenId Token ID of the ROColor
     */
    function _allowOnlyColorOwner(uint256 tokenId) internal view {
        address colorOwner = _requireOwned(tokenId);
        if (colorOwner != _msgSender()) revert ERC721IncorrectOwner(_msgSender(), tokenId, colorOwner);
    }
}
