# mwrust Library

The `mwrust` namespace provides a set of tools for interacting with wallets and signing transactions. This library is designed to facilitate wallet generation, transaction signing, and related functionality in a structured and easy-to-use API.

## Features

- Generate mnemonic phrases for wallet creation.
- Create wallets with customizable phrases and passwords.
- Sign raw transactions securely using wallet credentials.

## Namespace

The library exposes the `mwrust` namespace with the following functions and types:

### Functions

#### `genPhrase(wordCount: UInt32) -> String`
Generates a mnemonic phrase with the specified word count.

- **Parameters**:
    - `wordCount`: Number of words in the generated mnemonic phrase (e.g., 12, 15, 24).
- **Returns**:
    - A `String` containing the generated mnemonic phrase.

#### Example:
```swift
let phrase = genPhrase(wordCount: 12)
```

---

#### `createWallet(phrase: String, password: String, networkEnv: String, walletName: String) -> MinWallet`
Creates a wallet based on the provided mnemonic phrase, password, and network environment.

- **Parameters**:
    - `phrase`: The mnemonic phrase used to derive the wallet.
    - `password`: A user-defined password for encrypting the wallet's private key.
    - `networkEnv`: The network environment for the wallet (e.g., `"mainnet"` or `"preprod"`).
    - `walletName`: The Name of Wallet.
- **Returns**:
    - A `MinWallet` object containing wallet details.

#### Example:
```swift
let wallet = createWallet(
    phrase: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
    password: "secure_password",
    networkEnv: "preprod",
    walletName: "My MinWallet"
)
```

---

#### `signTx(wallet: MinWallet, password: String, accountIndex: UInt32, txRaw: String) -> String`
Signs a raw transaction using the provided wallet.

- **Parameters**:
    - `wallet`: A `MinWallet` object containing wallet details.
    - `password`: The password used to decrypt the wallet's private key.
    - `accountIndex`: The account index to sign the transaction from (default `accountIndex = 0`).
    - `txRaw`: The raw transaction string to be signed.
- **Returns**:
    - A signed transaction `String`.
---

#### `change_password(wallet: MinWallet, current_password: String, new_password: String) -> MinWallet`
Changes the password of a given wallet.

- **Parameters**:
  - `wallet`: A `MinWallet` object containing wallet details.
  - `current_password`: The current password used to decrypt the wallet.
  - `new_password`: The new password to set for the wallet.
- **Returns**:
  - An updated `MinWallet` object with the new password applied.

---

#### `verify_password(wallet: MinWallet, password: String) -> boolean`
Verifies whether the provided password matches the wallet's password.

- **Parameters**:
  - `wallet`: A `MinWallet` object containing wallet details.
  - `password`: The password to be verified.
- **Returns**:
  - A `boolean` indicating whether the password is correct (`true`) or incorrect (`false`).

---

#### `export_wallet(wallet: MinWallet, password: String, network_env: String) -> String`
Exports the wallet's data as a string for backup or transfer purposes.

- **Parameters**:
  - `wallet`: A `MinWallet` object containing wallet details.
  - `password`: The password used to encrypt the exported wallet data.
  - `network_env`: The network environment for which the wallet data is exported (e.g., `mainnet` or `testnet`).
- **Returns**:
  - A `String` containing the encrypted wallet data.

---

#### `import_wallet(data: String, password: String, wallet_name: String) -> MinWallet`
Imports a wallet from encrypted data.

- **Parameters**:
  - `data`: The encrypted wallet data as a string.
  - `password`: The password to decrypt the wallet data.
  - `wallet_name`: The name to assign to the imported wallet.
- **Returns**:
  - A `MinWallet` object representing the imported wallet.

---

#### `get_wallet_name_from_export_wallet(data: String) -> String`
Retrieves the wallet name from exported wallet data.

- **Parameters**:
  - `data`: The exported wallet data as a string.
- **Returns**:
  - A `String` containing the wallet name.

#### Example:
```swift
let signedTx = signTx(
    wallet: wallet,
    password: "secure_password",
    accountIndex: 0,
    txRaw: "raw_tx_data"
)
```

---

### Types

### `MinWallet`
A dictionary-like object containing details of a wallet.

- **Fields**:
    - `address` (`String`): The wallet's address.
    - `networkId` (`UInt32`): The ID of the network the wallet belongs to (mainnet: 764824073, preprod: 1).
    - `accountIndex` (`UInt32`): The account index within the wallet.
    - `encryptedKey` (`UInt32`): The wallet's encrypted private key.
    - `walletName` (`String`): the wallet's name.

#### Example:
```swift
let wallet = MinWallet(
    address: "addr_test1...",
    networkId: 1,
    accountIndex: 0,
    encryptedKey: "<encrypted_data>",
    walletName: "My MinWallet"
)
```

## Usage Examples

### Generate a Mnemonic Phrase
```swift
let phrase = genPhrase(wordCount: UInt32) -> String
```

### Create a Wallet
```swift
let wallet = createWallet(
    phrase: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
    password: "secure_password",
    networkEnv: "preprod"
)
```

### Sign a Transaction
```swift
let signedTx = signTx(
    wallet: wallet,
    password: "secure_password",
    accountIndex: 0,
    txRaw: "raw_tx_data"
)
```
