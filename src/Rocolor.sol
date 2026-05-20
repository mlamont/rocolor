// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

// TODO install depedencies before import
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

/**
 * @title ROColor
 * @author Merrill B. Lamont III (rockopera.eth)
 * @notice Own a color. Name that color. Make art onchain.
 * @dev Onchain art tech for onchain art work: 1 NFT color swatch for each of the 16M+ web colors.
 */
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
    uint256 private constant COLOR_NAME_MAX_LENGTH = 32;
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

    // TODO emit when storage variable updated ("nounVerbed")
    // TODO go for cohesive naming

    event ROColor__DepositReceived(address indexed sender, uint256 indexed amount);
    event ROColor__Rename(string indexed from, string indexed to, uint256 indexed tokenId);
    event ROColor__ContractBalanceWithdrawalPassed(uint256 indexed contractBalance);

    /****
    ***** ERRORS
    ****/

    // TODO go for cohesive naming ("nounAdj")
    error ROColor__TokenIdTooBig(uint256 tokenId);
    error ROColor__HexTripletLengthInvalid(string hexTriplet);
    error ROColor__HexTripletNumeralInvalid(bytes1 numeral);
    error ROColor__ColorNameTooBig(string colorName);
    error ROColor__FundsInsufficient();
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

    // TODO deep review of each line
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
     * @dev Converts hex triplet to tokenId, does checks, then passes to internal function
     * @dev Reverts if hex triplet is not exactly 6 bytes
     * @dev Reverts if a hex triplet byte is not a hexadecimal numeral
     * @dev Reverts if calculated tokenId is 2^24 or greater
     * @dev Reverts if name length is over 32 bytes
     * @dev Reverts if funds are less than the price of the color token
     * @dev Reverts if minting to the burn address
     * @dev Reverts if token already exists
     * @dev Emits a Transfer event
     * @dev Emits a ROColor__Rename event
     * @param hexTriplet Hex triplet of the ROColor
     * @param colorName Name of the ROColor
     */
    function mintColor(string calldata hexTriplet, string calldata colorName) external payable {
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
     * @dev Reverts if name length is over 32 bytes
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

    // change to external if can reduce the cognitive overhead for auditors
    // ...b/c it reduces the number of possible contexts in which the function can be called

    // NOTE: this is the function to optimize the most: called all the time!
    // TODO rename 'a' to 'asciiNumber'? also, the casts seem awkward
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
            uint256 a = uint8(hexTripletByte);
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
     * @notice Gets the tokenURI, with SVG picture, of a ROColor token
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

    // TODO make this payable?
    // TODO: learn & use: bit operations & bitmaps to reduce comparisons, and punt price check to end
    // TODO: investigate WARNING: minting is a source of reentrancy: it calls IERC721Receiver().onERC721received()
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

    // TODO comment to include color names w/ tokenIds
    // TODO learn & use: bit operations & bitmaps to reduce comparisons
    // TODO if & elseif instead of 2 separate ifs
    // TODO investigate if can say token IS IN {255, 65280, ...}
    // TODO consider unchecked {}
    /**
     * @notice Gets the price of a ROColor token
     * @dev Constructs price as the product of a minimum and a factor representing pricing tiers
     * @param tokenId Token ID of the ROColor
     * @return colorPrice Price of the ROColor
     */
    function _getColorPrice(uint256 tokenId) internal pure returns (uint256 colorPrice) {
        uint256 colorPriceMultiplier = 1;

        // if tokenId if the biggies, then multiplier is biggest
        if (tokenId == 0 || tokenId == TOKEN_ID_MAX) {
            colorPriceMultiplier = 10000;
        }

        // if tokenId is the middies, then multiplier is middest
        if (
            tokenId == 255 || tokenId == 65280 || tokenId == 16711680 || tokenId == 65535 || tokenId == 16711935
                || tokenId == 16776960
        ) {
            colorPriceMultiplier = 1000;
        }
        colorPrice = COLOR_PRICE_MIN * colorPriceMultiplier;
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
