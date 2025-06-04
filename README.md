# BitcoinMarket

A secure, decentralized marketplace smart contract built on the Stacks blockchain, enabling direct sales, auctions, and brand verification with Bitcoin settlement security.

## Overview

BitcoinMarket leverages the Stacks blockchain to create a trustless e-commerce platform where brands can list products for direct sale or auction, while maintaining the security guarantees of Bitcoin. The platform includes brand verification, review systems, and automated fee distribution.

## Features

### 🏪 Brand Management

- **Brand Registration**: Businesses can register their brand on the platform
- **Brand Verification**: Contract owner can verify legitimate brands for trust indicators
- **Decentralized Identity**: Brand profiles stored on-chain with creation timestamps

### 💰 Direct Sales

- **Product Listings**: Brands can list products with descriptions and fixed prices
- **Instant Purchase**: Buyers can purchase products immediately with STX tokens
- **Automated Payments**: Smart contract handles fee distribution and seller payments

### 🎯 Auction System

- **Timed Auctions**: Create auctions with customizable duration and minimum prices
- **Competitive Bidding**: Users can place bids with automatic refunds for outbid participants
- **Automated Settlement**: Auction completion triggers automatic fund distribution

### ⭐ Review System

- **Product Reviews**: Buyers can leave ratings (1-5 stars) and comments
- **Transparent Feedback**: All reviews stored on-chain for transparency
- **Quality Assurance**: Helps buyers make informed decisions

### 💎 Security Features

- **Bitcoin Security**: Inherits Bitcoin's security through Stacks blockchain
- **Access Control**: Role-based permissions for critical functions
- **Fund Safety**: Automatic escrow during auctions with guaranteed refunds

## Technical Specifications

### Platform Economics

- **Platform Fee**: 2.5% (25 basis points) on all transactions
- **Currency**: STX (Stacks tokens)
- **Settlement**: Immediate for direct sales, automated for auctions

### Smart Contract Architecture

#### Data Structures

- **Brands Map**: Stores brand profiles with verification status
- **Products Map**: Contains product listings with metadata and pricing
- **Auctions Map**: Manages auction state and bidding information
- **Reviews Map**: Stores customer feedback and ratings

#### Key Functions

**Brand Management**

- `register-brand`: Register a new brand on the platform
- `verify-brand`: Owner-only function to verify legitimate brands

**Direct Sales**

- `list-product`: Create a new product listing for immediate sale
- `purchase-product`: Buy a product instantly with automatic payment processing

**Auction System**

- `create-auction`: Launch a timed auction for a product
- `place-bid`: Submit competitive bids with automatic escrow
- `end-auction`: Finalize auction and distribute funds

**Review System**

- `add-review`: Submit product reviews and ratings

**Query Functions**

- `get-product`: Retrieve product information
- `get-brand`: Get brand profile data
- `get-auction`: View auction details and current bids
- `get-review`: Access customer reviews

## Getting Started

### Prerequisites

- Stacks wallet with STX tokens
- Access to Stacks blockchain (mainnet or testnet)

### For Brands

1. Register your brand using `register-brand`
2. Wait for verification (optional but recommended)
3. List products using `list-product` or `create-auction`
4. Monitor sales and manage inventory

### For Buyers

1. Browse available products using read-only functions
2. Purchase products directly with `purchase-product`
3. Participate in auctions using `place-bid`
4. Leave reviews after purchases with `add-review`

## Error Codes

| Code | Description |
|------|-------------|
| 100  | Owner-only function access denied |
| 101  | Brand not registered or unauthorized |
| 102  | Invalid price or empty required fields |
| 103  | Product listing not found |
| 104  | Insufficient funds for transaction |
| 105  | Auction has ended |
| 106  | Bid amount too low |
| 107  | No active auction found |
| 108  | Invalid auction duration |
| 109  | Invalid rating value |

## Security Considerations

- All transactions are atomic and secured by Bitcoin's consensus
- Funds are held in escrow during auctions to prevent fraud
- Brand verification adds trust layers without compromising decentralization
- Review system prevents manipulation through on-chain transparency

## Contract Deployment

The contract can be deployed on Stacks mainnet or testnet. Ensure proper testing on testnet before mainnet deployment.

## License

This project is open source and available under standard software licenses.

## Contributing

Contributions are welcome! Please ensure all code follows Clarity best practices and includes appropriate test coverage.

## Support

For technical issues or questions about the BitcoinMarket smart contract, please refer to the Stacks documentation or community forums.
