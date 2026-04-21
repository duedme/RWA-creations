# RWA-creations Project Documentation

This project is a **collectible card tokenization system** built with Solidity smart contracts, designed to be sold on marketplaces such as OpenSea. Each physical or digital card is divided into multiple "fractions" (tokens) following the ERC-1155 standard, allowing several people to own a share of the same card.

## What does the system do?

The main contract `CollectibleCard.sol` allows creating digital cards with a name, description, number of fractions, price per fraction, and a royalty percentage for the creator. It uses **OpenZeppelin** contracts (version 5.6.1) to guarantee security, including access control (`AccessManaged`), emergency pausing (`Pausable`), and supply tracking (`Supply`).

### Main functions

- **createCard**: creates a new card and mints (generates) all of its fractions to an address.
- **modifyPrice / modifyRoyalty**: allows the administrator to adjust the price and royalties.
- **freezeMetadata**: freezes a card's metadata so nobody can change it (important for trust on OpenSea).
- **royaltyInfo**: implements the EIP-2981 standard that OpenSea uses to pay royalties automatically.
- **pause / unpause**: allows stopping all transfers in case of emergency.

## Prerequisites

The following must be installed:

- **Git** (to clone the repository)
- **Foundry** (tool that includes `forge`, `cast`, and `anvil`)
- A **wallet** with funds on the network where the deployment will take place (e.g. Sepolia, Base, Ethereum)
- An **RPC URL** from a provider such as Alchemy or Infura

## Installing Foundry

Foundry is the "workshop" where the contract is compiled and tested. On Linux, macOS, or WSL, to open a terminal and run:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

The first command downloads the installer, and `foundryup` installs the latest versions of `forge`, `cast`, `anvil`, and `chisel`.

## Cloning and preparing the project

```bash
git clone <repo-url> RWA-creations
cd RWA-creations
forge install
```

The `forge install` command downloads the dependencies listed in `foundry.lock`: `forge-std v1.15.0`, `openzeppelin-contracts v5.6.1`, and `openzeppelin-contracts-upgradeable v5.6.1`.

## How to run it

### Compile the contract
```bash
forge build
```
This compiles the `src/CollectibleCard.sol` file using the paths defined in `remappings.txt`.

### Run the tests
```bash
forge test
```
Note: the `test/Counter.t.sol` file is currently empty, so there are no real tests yet.

### Local simulation (optional)
To spin up a local blockchain, run:
```bash
anvil
```
This provides a free test network at `http://127.0.0.1:8545` with preloaded accounts.

## How to deploy

Since the contract is **upgradeable** and inherits from `Initializable`, it does not use a normal constructor; instead it uses the `initialize(address initialAuthority, address royalRetriever)` function. Deployment is normally done behind a proxy.

### Simplified steps

1. **Configure environment variables** in a `.env` file:
   ```bash
   PRIVATE_KEY=0xYourPrivateKey
   RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY
   ETHERSCAN_API_KEY=YourEtherscanKey
   ```

2. **Deploy the contract** with forge create:
   ```bash
   source .env
   forge create src/CollectibleCard.sol:CollectibleCard \
     --rpc-url $RPC_URL \
     --private-key $PRIVATE_KEY \
     --broadcast
   ```

3. **Initialize the contract** (because the constructor is disabled with `_disableInitializers()`):
   ```bash
   cast send <CONTRACT_ADDRESS> \
     "initialize(address,address)" <ADMIN_ADDRESS> <ROYALTY_RECEIVER> \
     --rpc-url $RPC_URL --private-key $PRIVATE_KEY
   ```

4. **Verify the contract on Etherscan** so OpenSea recognizes it correctly:
   ```bash
   forge verify-contract <ADDRESS> src/CollectibleCard.sol:CollectibleCard \
     --chain sepolia --etherscan-api-key $ETHERSCAN_API_KEY
   ```

5. **Create a card** (once in production):
   ```bash
   cast send <ADDRESS> \
     "createCard(address,string,string,uint16,string,uint256,uint16)" \
     <recipient> "My Card" "Description" 100 "ipfs://.../meta.json" 1000000000000000 500 \
     --rpc-url $RPC_URL --private-key $PRIVATE_KEY
   ```
   The last number (500) represents 5% royalties, since the contract works in base 10000 (100% = 10000).

## Listing on OpenSea

Once deployed and with cards created, OpenSea automatically detects the ERC-1155 tokens using the metadata from the `tokenURI` (typically an IPFS link with JSON and an image). The contract already implements the EIP-2981 standard (interface `0x2a55205a`), which means OpenSea will recognize and pay royalties automatically.

## Repository structure

| File | Purpose |
|---|---|
| `src/CollectibleCard.sol` | Main tokenization contract |
| `script/Counter.s.sol` | Deploy script (currently empty) |
| `test/Counter.t.sol` | Test file (empty) |
| `foundry.toml` | Foundry configuration |
| `remappings.txt` | Paths to the OpenZeppelin libraries |