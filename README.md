# MinWallet iOS

MinWallet is a secure, user-friendly mobile wallet for the Cardano blockchain, developed by Minswap Labs. It allows users to manage their ADA and other Cardano assets, track their portfolio, and perform swaps seamlessly.

## Features 🌟

- **Wallet Management:** Create or restore wallets using industry-standard recovery phrases (BIP-39).
- **Asset Portfolio:** Real-time tracking of your ADA and Cardano native tokens.
- **Send & Receive:** Securely send and receive tokens with QR code support.
- **DEX Integration:** Swap functionality powered by Minswap DEX.
- **Order History:** Track your open and past orders with detailed status updates.
- **Security:** Protected by biometric authentication (Face ID/Touch ID) and secure keychain storage.

## Architecture 🏗️

MinWallet iOS is built using a modern tech stack:

- **UI:** SwiftUI for a native and responsive user experience.
- **Core Logic:** Rust for high-performance and secure cryptographic operations.
- **Network:** GraphQL and RESTful APIs for efficient data fetching.
- **Dependency Management:** Swift Package Manager (SPM).

## Getting Started 🚀

### Prerequisites

- **macOS** with the latest version of **Xcode**.
- **Rust Toolchain:** Installed via [rustup](https://rustup.rs/).

### Setup Instructions

1. **Clone the repository:**

   ```bash
   git clone https://github.com/minswap/minwallet-ios.git
   cd minwallet-ios
   ```

2. **Build the Rust Core:**
   The app depends on a Rust library for cryptographic functions. Build it by running:

   ```bash
   cd rust
   ./build.sh
   cd ..
   ```

3. **Open the Xcode Project:**

   ```bash
   open MinWallet.xcodeproj
   ```

## Development Guide 💻

### Code Formatting

We use `swift-format` to keep the codebase clean.

Format your code:

```bash
swift format format -r -p -i MinWallet
```

Lint your code:

```bash
swift format lint -r -p MinWallet
```

## Contributing 🤝

We welcome contributions! Please see our [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to get started.

## License 📄

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Security 🛡️

If you find a security vulnerability, please report it following our [Security Policy](SECURITY.md).

---

Built with ❤️ by [Minswap Labs](https://minswap.org).
