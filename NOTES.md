## Notes On Starting Again

The intent of refreshing the RockoperaColor project is to capitalize on recently acquired skills and approaches, resulting in a higher quality product I can more confidently use on its own, and as a basis for the rest of an ecosystem for fully onchain artistry. The following is this journey, documented with varying levels of detail.

## Prepare The Environment

Lay the groundwork with one-line commands, typed in the terminal.

```
mkdir rocolor
cd rocolor
foundryup
forge --version
forge init
```

I was hoping for a Forge version of `1.5.1-stable`, which I got because I installed Foundry recently, and now I have a project in that `rocolor` folder.

Opening this folder in VS Code, the 'Source Control' tab on the left was where I could start a 'rocolor' repository, and then publish (private) to GitHub, an account for which I had already set up and connected to VS Code via a GH extension.

After commiting with a message, it shows in GitHub.

If you're like me, this is the part where you sigh with relief.

## Code

Code a `.sol` file in the `src` folder, and type in the terminal `forge build` to have it compile, debugging any issues along the way, and commiting to GH along the way.

I started with simple `setName()` and `getName()` functions.

## Deploy Locally

Foundry is a great toolchain for Solidity smart contract development! Run the `anvil` command, and you get a local blockchain started up, it's RPC URL, and 10 funded accounts with their private keys.

Open up a terminal that's separate from VS Code for this next command:

```
cast wallet import anvil0 --interactive
```

When prompted, enter the private key of Anvil's Account #0, and then a password to access this account (it's 'keystore password'). While this is overkill for using fake funds on a local blockchain, storing Anvil Account #0's private key in an encrypted keystore is more secure than storing it as plain text in a `.env` file, so this becomes a preferred process I repeat when using real funds, for later deploying to a public testnet (and beyond!). Doing this in a terminal that is not built in to VS Code is an added safety precaution, so let's return to VS Code's terminal for the following.

```
forge create src/Rocolor.sol:Rocolor --rpc-url http://127.0.0.1:8545 --from <Anvil Account #0's Address> --account anvil0 --broadcast -vvvv
```

When prompted, enter the keystore password of Anvil's Account #0, and then behold! We will see output indicating the deployer address is Account0's address, that the contract was deployed to a particular address, and the transaction hash.

## Interacting Locally

```
cast send <Contract Address> "setName(string)" Alice --rpc-url http://127.0.0.1:8545 --account anvil0
```

Enter the keystore password for 'anvil0', and we have set the 'name' to Alice. Hopefully.

```
cast call <Contract Address> "getName()" --rpc-url http://127.0.0.1:8545
```

This is just reading from the blockchain, and not changing it via a signed transaction, so no need to involve a private key. Notice the more read-like `cast call` command is used instead of the more write-like `cast send`. The output here is a lot of hexadecimal data.

```
cast to-ascii <hex data>
```

Et voila, we see that all that hexadecimal data was just the blockchain's way of saying, "Alice".

## Deploying To Testnet

3 steps to start interacting with the contract from the Sepolia public testnet: create a keystore for an account with real (SepoliaETH) funds, deploy to Sepolia, verify the contract.

Again, in a separate terminal window, not a part of VS Code:

```
cast wallet import realfundslivehere --interactive
```

At the prompts, enter the private key, and then a password for the locally encrypted 'realfundslivehere' keystore account.

Back in VS Code's terminal:

```
forge create src/Rocolor.sol:Rocolor --rpc-url <Sepolia URL including an API key> --from <realfundslivehere's Address> --account realfundslivehere --broadcast -vvvv
```

I already have an Infura account, with a free API key, and they share the full RPC URL for Sepolia. It's very friendly, and Alchemy has a similar experience, but I went with Infura due to technical issues in my smart contract development using a previous toolchain. Long story. I also have an Etherscan account, with a free API key, for verifying on the Etherscan block explorer.

```
forge verify-contract <Contract Address> src/Rocolor.sol:Rocolor --chain sepolia --etherscan-api-key <that Etherscan API key>
```

## Interacting Via Testnet

On the Etherscan website, ensuring I was on the Sepolia testnet portion, I:

- search for the contract address
- select the 'Contract' button/tab mid-way down the page
- select the 'Write' button to see those functions
- interact with the `setName` function to set the name to 'Bob'
- sign the transaction, likely via your Metamask extension, with SepoliaETH funds we hopefully have
- select the 'Read' button
- interact with the `getName` function to see the name of 'Bob'

Do a little dance.

## Building More

This was a simple contract. The below are random notes I felt like documenting as I make this a more complicated and interesting one.

- install before importing: `forge install OpenZeppelin/openzeppelin-contracts`
- cannot directly cast `bytes` to/from `byte[]`
