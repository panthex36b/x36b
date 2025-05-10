# Panthex 36B Token

## 📜 Overview

**Name:** Panthex 36B  
**Ticker:** X36B  
**Standard:** TRC-20  
**Blockchain:** Tron  
**Total Supply:** 50,000,000,000 (up to 18 decimals)  
**Website:** https://x36b.com  
**Whitepaper:** https://docs.x36b.com/whitepaper.pdf

## 🎯 Token Economics

**Purpose:** A deflationary model designed for continuous appreciation and financial sustainability.

### 1. Supply & Distribution

| Category                 | % of Supply |         Amount | Wallet Address                                     |
| ------------------------ | ----------: | -------------: | -------------------------------------------------- |
| Qualified Institutions   |        50 % | 25,000,000,000 | `TVPNvdvTGMrtm43wpnUtr4pt35aFLSu8Kc`               |
| Licensed Exchanges       |        30 % | 15,000,000,000 | `TScNnUAtCJWiPt3y8fuFQ8aaip3uXZxukJ`               |
| Team & Advisors (vested) |        10 % |  5,000,000,000 | `TVQQLKyonfwLJbx1fxXH29ujDWgxPMH9Xe` (locked 12 m) |
| Strategic Reserve        |        10 % |  5,000,000,000 | `TXdNTmLWhkDiAFeNGJwY7ieU8fgmJRqqAC`               |

**Deflationary Supply Evolution**

- Year 1: 50,000,000,000

### 2. Burning Mechanism

- **Transaction Fee:** 0.1% per transfer  
- **Fee Split:**
  - 50 % → _burn_ (immediate token destruction)  
  - 40 % → _Treasury_ (100 % converted to Bitcoin)  
  - 10 % → _Strategic Reserve_ (100 % converted to APY-generating stablecoins)

## 🏦 Treasury & Strategic Reserve

- **Treasury (40 % of fees):** Continuous custody in Bitcoin as a hedge.  
- **Strategic Reserve (10 % of fees):** Generates yield in stablecoins to fund operations and partnerships.

## 🏛️ Governance & Transparency

- **Owner:** Only the deployer’s wallet (`Issuer`) can perform critical updates.  
- **Document Management:** Each document version is recorded on-chain via ERC-1643, emitting events for a complete history.

## 📄 Registered Documents

| File                                                   | HTTP URI                                                                                                  | Keccak‑256 Hash                                                       |
|--------------------------------------------------------|-----------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------|
| `042424-EUCLTN-7-FLAVIO-FERREIRA-2036-216066_v1.pdf`   | `https://docs.x36b.com/042424-EUCLTN-7-FLAVIO-FERREIRA-2036-216066_v1.pdf`                                  | `0x5bc62a2568c66d2eed740c6d63f133c107b79836aff08dd8ea3538d94e0d4aaf`   |
| `091224-LETTER-FROM-EUROCLEAR-LTNZ-216066_v1.pdf`      | `https://docs.x36b.com/091224-LETTER-FROM-EUROCLEAR-LTNZ-216066_v1.pdf`                                     | `0x0784e626d86ab30ccad6a4b67f0b76c7516d4658f98dab066d3bcf09669e72a7`   |

## 🔍 How to Verify Locally

You can verify each PDF’s integrity on Linux, macOS, or Windows.

### Linux / macOS

1. **OpenSSL (SHA3-256):**  
   ```bash
   openssl dgst -sha3-256 docs/MY_FILE.pdf
   ```  
   Expected output:
   ```
   SHA3-256(docs/MY_FILE.pdf)= 5bc62a2568c66d2eed740c6d63f133c107b79836aff08dd8ea3538d94e0d4aaf
   ```
2. **Node.js + Ethers.js (Keccak-256):**
   ```bash
   npm install -g ethers
   node -e "const fs=require('fs'); const { keccak256, arrayify } = require('ethers').utils; console.log(keccak256(arrayify(fs.readFileSync('docs/MY_FILE.pdf'))));"
   ```

### Windows (PowerShell)

1. **Node.js + Ethers.js (Keccak-256):**
   ```powershell
   npm install -g ethers
   node -e "const fs=require('fs'); const { keccak256, arrayify } = require('ethers').utils; console.log(keccak256(arrayify(fs.readFileSync('docs\\MY_FILE.pdf'))));"
   ```
2. **PowerShell (SHA256) [optional]:**
   ```powershell
   Get-FileHash -Path .\\docs\\MY_FILE.pdf -Algorithm SHA256
   ```

Replace `MY_FILE.pdf` with the actual PDF filename (e.g., `042424-EUCLTN-7-FLAVIO-FERREIRA-2036-216066_v1.pdf`).

## 🔗 Addresses

- **Issuer:** `TBSVX8zUUaSWBSEJLQsdcoGZzVpE9Nyt4W`  
- **Treasury:** `TSksxaxAKXocUd6EbaAtHKxHeMA3f5CPNw`  
- **Contract Address:** `TYyyLvxPEKSxzrfX8SuDs96cZBnkyCsP7C`