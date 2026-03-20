# Rayls Facture Hackathon v2 — RLS Token

[![License: Proprietary](https://img.shields.io/badge/License-Proprietary-red.svg)](./LICENSE)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.24-blue)](https://soliditylang.org/)
[![ERC-20](https://img.shields.io/badge/ERC--20-Deflationary-orange)](https://eips.ethereum.org/EIPS/eip-20)
[![Rayls](https://img.shields.io/badge/Rayls-Testnet-purple)](https://testnet-explorer.rayls.com/)
[![Deployed](https://img.shields.io/badge/Status-Deployed-brightgreen)](https://testnet-explorer.rayls.com/)

> **RLS — Deflationary ERC-20 token on Rayls Testnet with 50% fee burn mechanism**

Built by [StrainUS (Dr Strain)](https://github.com/StrainUS) — All Rights Reserved 2026

---

## What Is This?

RLS is a deflationary ERC-20 token deployed on the Rayls Testnet. It implements a 50% fee burn mechanism — half of every transaction fee is permanently burned, reducing total supply over time. This creates deflationary pressure as token usage increases.

RLS serves as the utility/governance token for the StrainUS Rayls ecosystem.

---

## Tokenomics

| Metric | Value |
|---|---|
| Symbol | RLS |
| Total Supply | 368,000 RLS |
| Burn Mechanism | 50% of fees burned per transaction |
| Network | Rayls Testnet (Chain ID: 7295799) |
| Standard | ERC-20 |

---

## Deployed Contract

| Info | Value |
|---|---|
| Contract Address | `0x8A791620dd6260079BF849Dc5567aDC3F2FdC318` |
| Deploy TX | `0x1ad477967dc26d1bd3d51daa53f2200d7f5e10a777dd9699a972cfb140a2804c` |
| Explorer | [View on Rayls](https://testnet-explorer.rayls.com/address/0x8A791620dd6260079BF849Dc5567aDC3F2FdC318) |

---

## How the Burn Works
```
User sends transaction with fee = X RLS
├── 50% (X/2) → Goes to validator/fee recipient
└── 50% (X/2) → Permanently burned (sent to 0x000...dead)
```

Every transaction reduces total supply. Over time, as ecosystem activity grows, RLS becomes scarcer — driving deflationary value.

---

## Network
```
Network Name: Rayls Testnet
RPC URL:      https://testnet-rpc.rayls.com
Chain ID:     7295799
Symbol:       USDr (gas) / RLS (token)
Explorer:     https://testnet-explorer.rayls.com
Faucet:       https://devnet-dapp.rayls.com
```

---

## Ecosystem

| Component | Description | Link |
|---|---|---|
| RWA Protocol | Full Privacy Node + AI compliance | [rayls-hackathon-rwa-privacy](https://github.com/StrainUS/rayls-hackathon-rwa-privacy) |
| NFT Contracts | Quantum-resistant invoice NFTs | [FactureNFTQuantum](https://github.com/StrainUS/FactureNFTQuantum) |
| Marketplace | React frontend for trading | [rayls-marketplace-hackathon](https://github.com/StrainUS/rayls-marketplace-hackathon) |
| MVP Origin | Original invoice NFT MVP | [rayls-facture-hackathon](https://github.com/StrainUS/rayls-facture-hackathon) |

---

Copyright 2026 StrainUS (Dr Strain) — All Rights Reserved
