use bip39::{Language, Mnemonic};
use cardano_serialization_lib::{Address, BaseAddress, Bip32PrivateKey, Credential};

use crate::wallet::emip3::{decrypt_password, encrypt_password};

fn harden(index: u32) -> u32 {
    index | 0x80_00_00_00
}

pub trait WalletStaticMethods {
    fn phrase_to_entropy(phrase: &str) -> Option<Vec<u8>> {
        let mnemonic = Mnemonic::from_phrase(&phrase, Language::English);
        match mnemonic {
            Ok(data) => Some(data.entropy().to_vec()),
            Err(_) => None,
        }
    }

    fn entropy_to_root_key(entropy: &[u8]) -> Bip32PrivateKey {
        Bip32PrivateKey::from_bip39_entropy(entropy, "".as_bytes())
    }

    fn get_account(root_key: &Bip32PrivateKey, index: u32) -> Bip32PrivateKey {
        root_key
            .derive(harden(1852)) // purpose
            .derive(harden(1815)) // coin type
            .derive(harden(index))
    }

    fn get_address(account: &Bip32PrivateKey, network_id: u32) -> Address {
        let payment_key = account.derive(0).derive(0).to_raw_key();
        let payment_key_hash = payment_key.to_public().hash();
        let payment_credential = Credential::from_keyhash(&payment_key_hash);

        let stake_key = account.derive(2).derive(0).to_raw_key();
        let stake_key_hash = stake_key.to_public().hash();
        let stake_credential = Credential::from_keyhash(&stake_key_hash);

        BaseAddress::new(network_id as u8, &payment_credential, &stake_credential).to_address()
    }

    fn gen_encrypted_key(password: &str, root_key: &Bip32PrivateKey) -> Option<String> {
        let root_key_hex = root_key.to_hex();
        encrypt_password(password, root_key_hex.as_str())
    }

    fn get_root_key_from_password(
        password: &str,
        encrypted_key: &String,
    ) -> Option<Bip32PrivateKey> {
        let decrypted = match decrypt_password(password, encrypted_key) {
            Some(v) => v,
            None => return None,
        };
        match Bip32PrivateKey::from_hex(decrypted.as_str()) {
            Ok(v) => Some(v),
            Err(_) => None,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    struct TestWallet;

    impl WalletStaticMethods for TestWallet {}

    #[test]
    fn test_round_trip_root_key() {
        let seed = String::from(
            "detect amateur eternal elite dad kangaroo usual chase poem detail tumble amount",
        );
        let password = String::from("helloworld");
        let entropy = TestWallet::phrase_to_entropy(&seed).unwrap();
        let root_key = TestWallet::entropy_to_root_key(&entropy);
        let encrypted = TestWallet::gen_encrypted_key(&password, &root_key).unwrap();
        let decrypted = TestWallet::get_root_key_from_password(&password, &encrypted).unwrap();
        assert_eq!(root_key.to_hex(), decrypted.to_hex());
    }
}
