# 🎲 Loot Box Random Reward System

A blockchain-based loot box system built with Clarity smart contracts that demonstrates cryptographic randomness and reward distribution mechanics.

## 🚀 Features

- 📦 **Multiple Loot Box Tiers**: Bronze, Silver, and Gold boxes with different price points
- 🎯 **Rarity-Based Rewards**: 5-tier rarity system from Common to Mythic
- 🔐 **Cryptographic Randomness**: Pseudo-random generation using block hashes and player data
- 👥 **Player Inventory System**: Track and manage collected rewards
- 📊 **Player Statistics**: Monitor boxes opened, spending, and rare item collection
- 🔄 **Reward Trading**: Transfer rewards between players
- ⚙️ **Admin Controls**: Manage loot boxes, pricing, and availability

## 📋 Contract Overview

The system includes:
- **Loot Box Management**: Create, price, and manage different box types
- **Reward System**: Define rewards with rarity tiers and drop rates
- **Randomness Engine**: Generate pseudo-random numbers for fair distribution
- **Inventory Tracking**: Store player rewards and statistics
- **Trading Mechanism**: Enable peer-to-peer reward transfers

## 🎮 Usage Instructions

### For Players

#### Purchase a Loot Box
```clarity
(contract-call? .loot-box-random-reward-system purchase-loot-box u1)
```

#### Open a Loot Box
```clarity
(contract-call? .loot-box-random-reward-system open-loot-box u1)
```

#### Check Your Inventory
```clarity
(contract-call? .loot-box-random-reward-system get-player-total-inventory 'SP1EXAMPLE...)
```

#### Transfer Rewards
```clarity
(contract-call? .loot-box-random-reward-system transfer-reward 'SP1RECIPIENT... u1 u1)
```

#### View Your Stats
```clarity
(contract-call? .loot-box-random-reward-system get-player-stats 'SP1EXAMPLE...)
```

### For Administrators

#### Initialize Default Content
```clarity
(contract-call? .loot-box-random-reward-system initialize-default-content)
```

#### Create New Loot Box
```clarity
(contract-call? .loot-box-random-reward-system create-loot-box "Diamond Box" u20000000 u50)
```

#### Create New Reward
```clarity
(contract-call? .loot-box-random-reward-system create-reward "Dragon Blade" u1 u3 u5)
```

#### Toggle Box Availability
```clarity
(contract-call? .loot-box-random-reward-system toggle-loot-box-availability u1)
```

## 🎰 Rarity System

| Rarity Level | Name | Drop Rate | Bonus Points |
|--------------|------|-----------|--------------|
| 1 | 🌟 Mythic | 0.1% | 1000 |
| 2 | 🔥 Legendary | 0.9% | 500 |
| 3 | 💜 Epic | 4% | 200 |
| 4 | 🔵 Rare | 15% | 100 |
| 5 | ⚪ Common | 80% | 50 |

## 🔧 Development Setup

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks CLI tools

### Installation
```bash
git clone <repository-url>
cd loot-box-random-reward-system
clarinet check
```

### Testing
```bash
clarinet test
```

### Deployment
```bash
clarinet deploy --testnet
```

## 🏗️ Contract Architecture

The smart contract consists of several key components:

- **Data Storage**: Maps for loot boxes, rewards, and player data
- **Randomness Generation**: Cryptographic seed generation using block data
- **Reward Distribution**: Probability-based reward selection
- **Inventory Management**: Player reward tracking and transfers
- **Administrative Functions**: Owner-only management capabilities

## 📊 Default Configuration

The contract comes pre-configured with:

### Loot Boxes
- 📦 **Bronze Box**: 1 STX - 1000 available
- 🥈 **Silver Box**: 5 STX - 500 available  
- 🥇 **Gold Box**: 10 STX - 100 available

### Rewards
- ⚔️ **Common Sword** (Rarity 5) - 35% drop rate
- 🛡️ **Rare Shield** (Rarity 4) - 10% drop rate
- 🦾 **Epic Armor** (Rarity 3) - 4% drop rate
- 💎 **Legendary Gem** (Rarity 2) - 0.9% drop rate
- 👑 **Mythic Crown** (Rarity 1) - 0.1% drop rate

## 🔒 Security Features

- Owner-only administrative functions
- Balance validation before transactions
- Supply tracking to prevent overselling
- Secure random number generation
- Transfer validation for owned rewards

## 🎯 Learning Objectives

This project demonstrates:
- ✅ Blockchain-based randomness generation
- ✅ Probability distribution systems
- ✅ Digital asset management
- ✅ Economic game mechanics
- ✅ Smart contract security patterns

## 📜 License

MIT License - Feel free to use this for learning and development!

---

🎊 **Happy Gaming!** May the odds be ever in your favor! 🍀
