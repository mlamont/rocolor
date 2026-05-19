// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

// TODO install depedencies before import
// TODO use labeled imports
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract Rocolor is ERC721, Ownable {
    // State variables
    // think about options 4 constants & immutables & state variables, & capital'z'g
    // Only use private to intentionally prevent child contracts from
    // ...accessing the variable, prefer internal for flexibility.
    // Is calculating a value on the fly cheaper than storing it?
    /// @dev Custom string per unique tokenId, which can appear in the NFT pic.
    mapping(uint256 tokenId => string) internal _colorNames; // include "tokenId"? internal i/o private?
    string private _name; // gotta get rid of this one... already exists in ERC721
    uint256 private constant TOKEN_ID_MAX = 16777215;
    uint256 private constant HEX_TRIPLET_VALID_LENGTH = 6;
    bytes16 private constant HEX_SYMBOLS = "0123456789ABCDEF";
    uint256 private constant NUMBER_OF_BITS_IN_A_HEXADECIMAL = 4;

    // Events
    // TODO emit when storage variable updated ("nounVerbed")
    // TODO use prefix of contract__
    // TODO go for cohesive naming

    /// @notice Logs a deposit's sender and amount.
    event ROColor__DepositReceived(address sender, uint256 amount);
    event ROColor__Rename(string from, string to, uint256 tokenId);
    event ROColor__ContractBalanceWithdrawalPassed(uint256 contractBalance);

    // Errors
    // TODO use prefix of contract__
    // TODO go for cohesive naming ("nounAdj")
    error ROColor__TokenIdTooBig();
    error ROColor__HexTripletLengthInvalid(string hexTriplet);
    error ROColor__HexTripletNumeralInvalid(bytes1 numeral);
    error ROColor__DecimalTooBig(uint256 decimal);
    error ROColor__ContractBalanceWithdrawalFailed();
    error ROColor__ContractBalanceIsEmpty();

    // Modifiers
    // for gas: wrap internal functions
    // use to improve readability & decrease code duplication
    // yes, use natspec

    // constructor
    constructor() ERC721("ROColor", "ROC") Ownable(_msgSender()) {
        // starting stuff
    }

    // receive function (if exists)
    /// @notice Receive function to just receive sent funds, and emits an event.
    receive() external payable {
        emit ROColor__DepositReceived(_msgSender(), msg.value);
    }

    // fallback function (if exists)
    /// @notice Fallback function just receives any sent funds, and emits an event.
    fallback() external payable {
        emit ROColor__DepositReceived(_msgSender(), msg.value);
    }

    // external
    // TODO add nonReentrant modifier to each
    // ...REALLY?

    /// @notice Removes all stored funds from the contract
    /// @dev Only the contract owner can do this.
    function withdraw() external onlyOwner {
        // gotta ensure the checks-effects-interactions pattern is always in here
        uint256 balanceOfThisContract = address(this).balance;
        if (balanceOfThisContract == 0) revert ROColor__ContractBalanceIsEmpty();
        (bool success,) = owner().call{value: balanceOfThisContract}(""); // call() doesn't require owner() wrapped in payable()
        if (!success) revert ROColor__ContractBalanceWithdrawalFailed();
        // OLD: payable(owner()).transfer(balanceOfThisContract);
        emit ROColor__ContractBalanceWithdrawalPassed(balanceOfThisContract);
    }

    function mintColor(string calldata hexTriplet, string calldata colorName) external {
        uint256 tokenId = convertHexTripletToDecimal(hexTriplet);
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig();
        _mintColor(tokenId, colorName);
    }

    function changeColorName(string calldata hexTriplet, string calldata newColorName) external {
        uint256 tokenId = convertHexTripletToDecimal(hexTriplet);
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig();
        _onlyColorOwner(tokenId);
        _changeColorName(tokenId, newColorName);
    }

    function changeColorOwner(string calldata hexTriplet, address newColorOwner) external {
        uint256 tokenId = convertHexTripletToDecimal(hexTriplet);
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig();
        // _onlyColorOwner(tokenId); // these checks are already done in ERC721-level function called from below line
        _changeColorOwner(tokenId, newColorOwner);
    }

    function burnColor(string calldata hexTriplet) external {
        uint256 tokenId = convertHexTripletToDecimal(hexTriplet);
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig();
        _onlyColorOwner(tokenId);
        _burnColor(tokenId);
    }

    function getColorName(string calldata hexTriplet) external view returns (string memory) {
        uint256 tokenId = convertHexTripletToDecimal(hexTriplet);
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig();
        return _getColorName(tokenId);
    }

    function getColorOwner(string calldata hexTriplet) external view returns (address) {
        uint256 tokenId = convertHexTripletToDecimal(hexTriplet);
        if (tokenId > TOKEN_ID_MAX) revert ROColor__TokenIdTooBig();
        return _getColorOwner(tokenId);
    }

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

    // tokenId() will go here

    // internal
    function _mintColor(uint256 tokenId, string memory colorName) internal {
        _safeMint(_msgSender(), tokenId);
        _changeColorName(tokenId, colorName);
    }

    function _changeColorName(uint256 tokenId, string memory newColorName) internal {
        string memory oldColorName = _colorNames[tokenId];
        _colorNames[tokenId] = newColorName;
        emit ROColor__Rename(oldColorName, newColorName, tokenId);
    }

    function _changeColorOwner(uint256 tokenId, address newColorOwner) internal {
        _safeTransfer(_msgSender(), newColorOwner, tokenId);
        // will check for, & revert for, 3 different checks per _transfer()
        // reverts if newColorOwner is the Zero address
        // reverts if tokenId is owned by noone (existing owner is the Zero address)
        // reverts if tokenId is owned by someone else (existing owner isn't function-caller)
    }

    function _burnColor(uint256 tokenId) internal {
        // reset name to nothing, before burning
        _changeColorName(tokenId, "");
        // burn token
        _burn(tokenId);
        // reverts if tokenId is owned by noone (existing owner is the Zero address)
        // reverts if tokenId is owned by someone else
    }

    function _getColorName(uint256 tokenId) internal view returns (string memory) {
        return _colorNames[tokenId];
    }

    function _getColorOwner(uint256 tokenId) internal view returns (address) {
        return ownerOf(tokenId);
    }

    function _onlyColorOwner(uint256 tokenId) internal view {
        // reverts if tokenId is owned by noone (existing owner is the Zero address)
        address colorOwner = _requireOwned(tokenId);

        // reverts if tokenId is owned by someone else (existing owner isn't function-caller)
        if (colorOwner != _msgSender()) revert ERC721IncorrectOwner(_msgSender(), tokenId, colorOwner);
    }

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

// code outline of newer version
// only 1 task per 1 function, so embrace the smaller scope of activity, reflected in function name
// name functions like this: [verb: mint/burn, get/change]Color[aspect: owner/name], which'll always take a 'hexTriplet' param
// ...
/* mapping(uint256 => string) internal _colorNames; */
/*                                               _onlyColorOwner(tokenId) */
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
// tokenURI()
// ... TODO: put in NatSpec: where internal functions are unchecked (checks are in the external functions), beyond what ERC721 does
// ... TODO: CEI-PI / fn

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
