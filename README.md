# PropertyRentAgreement_SmartContract
A secure and decentralized Ethereum smart contract for managing property rental agreements with rent payments, security deposit handling, lease termination, and protection against reentrancy attacks.

## ✨ Features

* Create rental agreements with rent, security deposit, and lease period.
* Update rent and location before lease starts.
* Tenant can pay rent and security deposit securely.
* Owner can terminate lease and refund the deposit.
* Reentrancy protection using a custom `noReentrant` modifier.

## 🤖 Smart Contract Functions

### Owner Functions:

* `createRentalAgreement(...)`
* `updateRentAgreement(...)`
* `terminateLeaseAndRefundDeposit(...)`

### Tenant Functions:

* `payRent(...)`

### Public View:

* `getAgreementDetails(...)`

## 🔧 Tech Stack

* Solidity (v0.8.0)
* Ethereum EVM
* Remix IDE / Hardhat Compatible

## 🚀 How to Deploy

You can deploy the contract using:

* [Remix IDE](https://remix.ethereum.org)
* Hardhat or Truffle for local and testnet deployment

## 📄 License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT)

---

**Note:** This project is for educational purposes and not audited for production. Always test thoroughly before deploying on mainnet.

