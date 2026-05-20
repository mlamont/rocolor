## ROColor

**ROColor is a NFT collection of all 16.7M+ web colors, formed as native-onchain assets for pure Web3 artistry.**

This repository is a refresh of the backend (smart contract) & frontend (webpage) components of my RockoperaColor project, focusing on **better quality** and **better security**.

## Long Term Goal

To craft a higher quality native-onchain art primitive as a basis for future primitives, each composable in a native-onchain art studio, unlocking more & greater forms of artistry. This is inspired by how traditional finance has evolved via the blockchain capabilities of DeFi.

## Short Term Goal

To show that I am a technical project manager by building with the computer science skills & principles acquired through formal education undertaken in the first half of 2026. And, I mean, making money off of this would also be, like, really neat... I did with the currently live version, so I know it's totally possible!

## Plan

Rebuild two repositories into this one, tracked via the following...

### Backlog

- ~~review notes for backlog items, and loosely prioritize~~
- ~~use Solidity Style Guide's Layouts of a Contract & Functions~~
- ~~install dep'cies before import~~
- ~~modifier should be a wrapped internal function (for gas)~~
- ~~external functions += nonReentrant modifier~~
- ~~update storage variable, then emit an event ("nounVerb'd")~~
- ~~think about options 4 constants & immutables & state variables ... & capitalizing~~
- ~~custom errors & events: "contract\_\_" prefix, cohesive naming, do after state changes~~
- ~~use modifiers to improve readability & decrease code duplication~~
- ~~use label'd imports~~
- ~~LO NacentXYZ's DOCs RE sec'y~~
- ~~LO Solcurity Standard (sec'y & code quality)~~
- ~~high quality 1 function~~
- ~~high quality NatSpec for this 1 function~~
- ~~high quality unit testing for this 1 function~~
- ~~test writing: {Arrange, Act, Assert}~~
- ~~test += console.log~~
- ~~create a script for deploy'g... can then use for testing~~
- ~~write unit tests, then code, for converting decimal to colorhex~~
- ~~document the logic of the 2 conversion functions like a pro: what comments are before vs inline~~
- ~~name functions like this: [verb: mint/burn, get/change]Color[aspect: owner/name], which'll always take a 'hexTriplet' param~~
- ~~code all functions for free service~~
- have getter functions return a named variable, and NapSpec it (error on the side of readability & documentation, then scale back)
- code functions for incorporating price
- compare new functions to functions of previous version
- only 1 task per 1 function, so embrace the smaller scope of activity, reflected in function name
- CEI (Checks, Effects, Interactions) + PI (Protocol Invariants)
- for mathy bits: multiply before divide
- secure 'selfdestruct'
- DOC steps to code this PRJ for a newb
- testing suite & types: unit, integrations, coverage, (gas) snapshot, test --debug
- set & use Helper.Config.s.sol for NetworkConfig for deploy script
- test functions += modifiers (to modularize)
- maybe use a MAKE file
- cannot compare strings, so compare (bytes32) hashed encoded ones
- FO the invariants, then Fuzz Test 'em, e.g., conservation, solvency, monotonicity, bounds, access ctrl, state consistency
- do static analysis eg Slither / Mythril
- get auto-gen'g DOCs site
- set habit of reading rekt & audit reports
- test order: unit tests, test cov'ge, fuzz, static
- aim: readability ... in turn, improved maintainability
- Use the delete keyword when setting a variable to a zero value (0, false, "", etc).
- Comment the "why" as much as possible.
- Summarize the purpose and functionality of the contract with a @notice natspec comment. Document how the contract interacts with other contracts inside/outside the project in a @dev natspec comment.
- note: DoD: high quality
- front end on blog's server, later on an IPFS node hosted on that server, if possible
- explore this being a proxy contract, or utilizing a library / interface / abstract contract

## Donations

If you're intrigued or inspired by my Web3 explorations in artistry, I accept ETH at

- 0xa5bdBF3081A3c6a9740B33f2bdD3295C3fc15835 (rockopera.eth)

Rock on, every peoples!
