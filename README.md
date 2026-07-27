# UBI & Jobchain Marketplace — Web3 DeFi Ecosystem 💎

[![UBI Web3 CI](https://github.com/patofet/ubi/actions/workflows/ci.yml/badge.svg)](https://github.com/patofet/ubi/actions/workflows/ci.yml)
[![Solidity](https://img.shields.io/badge/Solidity-%5E0.8.4-363636.svg?logo=solidity)](https://docs.soliditylang.org/)
[![Hardhat](https://img.shields.io/badge/Built%20with-Hardhat-yellow.svg)](https://hardhat.org/)
[![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED.svg?logo=docker)](https://www.docker.com/)

A decentralized Web3 ecosystem featuring a Universal Basic Income (**UBI**) ERC-20 token distribution model integrated with an NFT Marketplace (**JobchainMarketplace**) for locked token collections and tiered asset pricing.

---

## 🏛️ Architecture Overview

The system is architected around two primary smart contract components deployed on EVM-compatible networks:

1. **`UBI.sol` (ERC-20 & Distributor)**:
   - Implements standard ERC-20 functionality with integrated burning mechanics (`burn()`).
   - Inherits from `ERC20Distributor` to manage systematic basic income token allocations.

2. **`JobchainMarketplace.sol` (NFT Marketplace & Factory)**:
   - Acts as a factory and decentralized exchange for ERC-721A collections (`ERC721ALockedTokens`).
   - **Permissioned Creation**: Utilizes access control (`toggleCreators`) where only whitelisted creators can deploy new collections.
   - **Quality-Tiered Pricing**: Dynamically maps quality tiers to specific UBI token prices (`pricesPerQuality`), enforcing automated ERC-20 allowance checks and token transfers upon purchase (`buyNFT`).

---

## 🚀 Quickstart (Docker Enabled)

You can run the entire Hardhat compilation and test suite in an isolated container without installing local Node.js or Web3 dependencies.

### 1. Build and Run Tests via Docker Compose
```bash
# Run the automated Hardhat test suite in Docker
docker compose run hardhat-test

# Compile contracts
docker compose run hardhat-compile
```

---

## 💻 Local Development Setup

If you prefer running locally with Node.js (v18+ recommended):

### 1. Install Dependencies
```bash
npm install
```

### 2. Compile Smart Contracts
```bash
npx hardhat compile
```

### 3. Run Test Suite
```bash
npm test
# or
npx hardhat test
```

---

## 🧪 Testing Coverage

The testing suite (`test/test_ubi.js`) covers:
- ✅ **Token Deployment**: Verification of UBI ERC-20 initialization, symbols, and initial states.
- ✅ **Access Control**: Validating admin ownership and dynamic creator whitelisting (`toggleCreators`).
- ✅ **Security Revert assertions**: Ensuring unauthorized addresses cannot deploy marketplace collections.

---

## 📄 License
This project is licensed under the ISC License.
