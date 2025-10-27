mod crypto;
pub mod network;
mod wallet;

use crate::crypto::blake2b256;
use crate::network::NetworkEnvironment;
use crate::wallet::embedded::WalletStaticMethods;
use bip39::{Language, Mnemonic, MnemonicType};
use cardano_serialization_lib::{
    make_vkey_witness, Bip32PrivateKey, PrivateKey, Transaction, TransactionHash,
    TransactionWitnessSet, Vkeywitnesses,
};
use serde::{Deserialize, Serialize};

// *************************** EXPORT ***************************
#[derive(Debug, Serialize, Deserialize)]
pub struct MinWallet {
    wallet_name: String,
    address: String,
    network_id: u32,
    encrypted_key: String,
    account_index: u32,
    public_key: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct EWType {
    wallet: EWWallet,
    settings: EWSettings,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct EWWallet {
    export: String,
    version: String,
    id: String,
    #[serde(rename = "networkId")]
    network_id: String,
    #[serde(rename = "signType")]
    sign_type: String,
    #[serde(rename = "rootKey")]
    root_key: EWRootKey,
    #[serde(rename = "accountList")]
    account_list: Vec<EWAccount>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct EWRootKey {
    #[serde(rename = "pub")]
    pub_key: String,
    prv: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct EWAccount {
    id: String,
    #[serde(rename = "pub")]
    pub_key: String,
    path: (u32, u32, u32),
    #[serde(rename = "signType")]
    sign_type: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct EWSettings {
    id: String,
    #[serde(rename = "networkId")]
    network_id: String,
    name: String,
}

pub fn gen_phrase(word_count: u32) -> Option<String> {
    // Match the word_count to the corresponding MnemonicType variant
    let m_type = match word_count {
        12 => MnemonicType::Words12,
        15 => MnemonicType::Words15,
        18 => MnemonicType::Words18,
        21 => MnemonicType::Words21,
        24 => MnemonicType::Words24,
        _ => return None,
    };

    // Create a new randomly generated mnemonic phrase
    let mnemonic = Mnemonic::new(m_type, Language::English);

    // Get the phrase as a string
    Some(mnemonic.phrase().to_string())
}

pub fn create_wallet(
    phrase: String,
    password: String,
    network_env: String,
    wallet_name: String,
) -> Option<MinWallet> {
    let network_environment = match NetworkEnvironment::from_string(network_env) {
        Some(v) => v,
        None => return None,
    };
    MinWallet::create(
        phrase.as_str(),
        password.as_str(),
        network_environment,
        wallet_name,
    )
}

pub fn sign_tx(
    wallet: MinWallet,
    password: String,
    account_index: u32,
    tx_raw: String,
) -> Option<String> {
    wallet.sign_tx(password.as_str(), account_index, tx_raw)
}

pub fn change_wallet_name(
    wallet: MinWallet,
    password: String,
    new_wallet_name: String,
) -> Option<MinWallet> {
    let encrypted_key = wallet.encrypted_key.clone();
    // verify password
    match MinWallet::get_root_key_from_password(password.as_str(), &encrypted_key) {
        Some(_) => Some(MinWallet {
            wallet_name: new_wallet_name,
            ..wallet
        }),
        None => None,
    }
}

pub fn change_password(
    wallet: MinWallet,
    current_password: String,
    new_password: String,
) -> Option<MinWallet> {
    // Retrieve the root key using the current password and the wallet's encrypted key
    let root_key = match MinWallet::get_root_key_from_password(
        current_password.as_str(),
        &wallet.encrypted_key,
    ) {
        Some(v) => v,
        None => return None,
    };

    // Generate a new encrypted key using the new password and the retrieved root key
    let new_encrypted_key = match MinWallet::gen_encrypted_key(new_password.as_str(), &root_key) {
        Some(v) => v,
        None => return None,
    };

    // Return a new MinWallet with the updated encrypted_key
    Some(MinWallet {
        encrypted_key: new_encrypted_key,
        ..wallet // Use the struct update syntax to copy the remaining fields
    })
}

pub fn verify_password(wallet: MinWallet, password: String) -> bool {
    match MinWallet::get_root_key_from_password(password.as_str(), &wallet.encrypted_key) {
        Some(_) => true,
        None => false,
    }
}

pub fn export_wallet(wallet: MinWallet, password: String, network_env: String) -> Option<String> {
    let network_environment = match NetworkEnvironment::from_string(network_env.clone()) {
        Some(v) => v,
        None => return None,
    };
    let network_suffix = match network_environment {
        NetworkEnvironment::Mainnet => "mm",
        NetworkEnvironment::Preprod => "pm",
        NetworkEnvironment::Preview => "pm",
    };
    let root_private_key =
        match MinWallet::get_root_key_from_password(password.as_str(), &wallet.encrypted_key) {
            Some(v) => v,
            None => return None,
        };
    let root_pub_key = root_private_key.to_public();
    let root_account_id = root_pub_key.to_bech32().as_str()[..16].to_string();

    let account_private_key = MinWallet::get_account(&root_private_key, 0);
    let account_public_key = account_private_key.to_public();
    let account_id = account_public_key.to_bech32().as_str()[..16].to_string();

    let wallet_export = EWType {
        wallet: EWWallet {
            export: "minswap".to_string(),
            version: "1.0.0".to_string(),
            id: root_account_id.clone() + "-" + network_suffix,
            network_id: network_env.clone(),
            sign_type: "mnemonic".to_string(),
            root_key: EWRootKey {
                pub_key: root_pub_key.to_bech32(),
                prv: root_private_key.to_hex(),
            },
            account_list: vec![EWAccount {
                id: account_id,
                pub_key: account_public_key.to_bech32(),
                path: (1852, 1815, 0),
                sign_type: "mnemonic".to_string(),
            }],
        },
        settings: EWSettings {
            id: root_account_id + "-" + network_suffix,
            network_id: network_env.clone(),
            name: wallet.wallet_name.clone(),
        },
    };
    match serde_json::to_string(&wallet_export) {
        Ok(v) => Some(v),
        Err(_) => None,
    }
}

pub fn get_wallet_name_from_export_wallet(data: String) -> Option<String> {
    let wallet_export: EWType = match serde_json::from_str(data.as_str()) {
        Ok(v) => v,
        Err(_) => return None,
    };
    Some(wallet_export.settings.name)
}

pub fn import_wallet(data: String, password: String, wallet_name: String) -> Option<MinWallet> {
    let wallet_export: EWType = match serde_json::from_str(data.as_str()) {
        Ok(v) => v,
        Err(_) => return None,
    };
    let root_key_hex = wallet_export.wallet.root_key.prv;
    let root_key = match Bip32PrivateKey::from_hex(root_key_hex.as_str()) {
        Ok(v) => v,
        Err(_) => return None,
    };
    let account_index = 0;
    let account_key = MinWallet::get_account(&root_key, account_index);
    let public_key = account_key.to_public().to_hex();

    // Encrypt root key with password
    let encrypted_key = match MinWallet::gen_encrypted_key(password.as_str(), &root_key) {
        Some(v) => v,
        None => return None,
    };

    // Derive network ID
    let network_env = wallet_export.wallet.network_id;
    let network_environment = match NetworkEnvironment::from_string(network_env) {
        Some(v) => v,
        None => return None,
    };
    let network_id = network_environment.to_network_id() as u32;

    // Generate addresses
    let address = MinWallet::get_address(&account_key, network_id);
    let address_bech32 = match address.to_bech32(None) {
        Ok(v) => v,
        Err(_) => return None,
    };
    Some(MinWallet {
        wallet_name,
        address: address_bech32,
        network_id,
        account_index,
        encrypted_key,
        public_key,
    })
}
// *************************** END EXPORT ***************************

impl WalletStaticMethods for MinWallet {}

impl MinWallet {
    pub fn create(
        mnemonic: &str,
        password: &str,
        network_environment: NetworkEnvironment,
        wallet_name: String,
    ) -> Option<Self> {
        let account_index = 0;

        // Convert mnemonic to entropy
        let entropy = match MinWallet::phrase_to_entropy(&mnemonic) {
            Some(entropy) => entropy,
            None => return None,
        };

        // Derive root key and account key
        let root_key = MinWallet::entropy_to_root_key(&entropy);
        let account_key = MinWallet::get_account(&root_key, account_index);
        let public_key = account_key.to_public().to_hex();

        // Encrypt root key with password
        let encrypted_key = match MinWallet::gen_encrypted_key(password, &root_key) {
            Some(key) => key,
            None => return None,
        };

        // Derive network ID
        let network_id = network_environment.to_network_id() as u32;

        // Generate addresses
        let address = MinWallet::get_address(&account_key, network_id);
        let address_bech32 = match address.to_bech32(None) {
            Ok(v) => v,
            Err(_) => return None,
        };
        Some(MinWallet {
            wallet_name,
            address: address_bech32,
            network_id,
            account_index,
            encrypted_key,
            public_key,
        })
    }

    pub fn get_private_key(&self, password: &str, account_index: u32) -> Option<PrivateKey> {
        let root_key = match MinWallet::get_root_key_from_password(&password, &self.encrypted_key) {
            Some(root_key) => root_key,
            None => return None,
        };
        let account_key = MinWallet::get_account(&root_key, account_index);
        let payment_key = account_key.derive(0).derive(0).to_raw_key();
        match PrivateKey::from_bech32(payment_key.to_bech32().as_ref()) {
            Ok(key) => Some(key),
            Err(_) => None,
        }
    }

    pub fn sign_tx(&self, password: &str, account_index: u32, tx_raw: String) -> Option<String> {
        let private_key = match self.get_private_key(password, account_index) {
            Some(private_key) => private_key,
            None => return None,
        };
        let tx = match Transaction::from_hex(tx_raw.as_str()) {
            Ok(tx) => tx,
            Err(_) => return None,
        };
        let tx_hash = TransactionHash::from(blake2b256(&tx.body().to_bytes()));
        let mut witness_set = TransactionWitnessSet::new();
        let mut v_key_witnesses = Vkeywitnesses::new();
        let v_key = make_vkey_witness(&tx_hash, &private_key);
        v_key_witnesses.add(&v_key);
        witness_set.set_vkeys(&v_key_witnesses);
        Some(witness_set.to_hex())
    }
}

uniffi::include_scaffolding!("mwrust");

#[cfg(test)]
mod tests {
    use super::*;
    use crate::crypto::hash_transaction;
    use cardano_serialization_lib::Transaction;

    #[test]
    fn test_change_wallet_name() {
        let phrase =
            "belt change crouch decorate advice emerge tongue loop cute olympic tuna donkey";
        let password = "Minswap@123456";
        let wallet_name = "My MinWallet".to_string();
        let wallet = create_wallet(
            phrase.to_string(),
            password.to_string(),
            "preprod".to_string(),
            wallet_name.clone(),
        )
        .unwrap();
        let new_wallet_name = "New Wallet Name";
        let new_wallet =
            change_wallet_name(wallet, password.to_string(), new_wallet_name.to_string()).unwrap();
        assert_eq!(new_wallet.wallet_name, new_wallet_name);
    }
    #[test]
    fn test_export_wallet() {
        let phrase =
            "belt change crouch decorate advice emerge tongue loop cute olympic tuna donkey";
        let password = "Minswap@123456";
        let wallet_name = "My MinWallet".to_string();
        let wallet = create_wallet(
            phrase.to_string(),
            password.to_string(),
            "preprod".to_string(),
            wallet_name.clone(),
        )
        .unwrap();
        let old_prk = wallet.get_private_key(password, 0).unwrap();
        let old_wallet_name = wallet.wallet_name.clone();
        let old_address = wallet.address.clone();
        let export_wallet_data =
            export_wallet(wallet, password.to_string(), "preprod".to_string()).unwrap();

        let round_trip_wallet =
            import_wallet(export_wallet_data, password.to_string(), wallet_name).unwrap();

        assert_eq!(old_wallet_name, round_trip_wallet.wallet_name);
        assert_eq!(old_address, round_trip_wallet.address);

        let new_prk = round_trip_wallet.get_private_key(password, 0).unwrap();
        assert_eq!(old_prk.to_hex(), new_prk.to_hex());
    }

    #[test]
    fn test_export_wallet2() {
        let data = r#"
        {
            "wallet": {
                "export": "minswap",
                "version": "1.0.0",
                "id": "xpub15ux84rpzhn8-pm",
                "networkId": "preprod",
                "signType": "mnemonic",
                "rootKey": {
                "pub": "xpub15ux84rpzhn8gpu9zk47cdmtdkvs6c3mxtnlf5vp30rwhq0ydmc7k88zdnygw2vlmkva5jzyc502mz6u6njjgkly39yn520k7v3axjwsmp0xx2",
                "prv": "c845ca25d1d945f80a4123b4fcf6f90f7a9af3784baf53fbf91ab80282ba09518ca7eb3598d21a933caab68b47426be9bfaf63aaba3e7ae705a65143ba861928639c4d9910e533fbb33b490898a3d5b16b9a9ca48b7c912927453ede647a693a"
                },
                "accountList": [
                {
                    "id": "xpub13saj9lmw6lm",
                    "pub": "xpub13saj9lmw6lmxscca2rsx2s2qawxvwuwt945ylrakaekrauy6k245vk0z7wm5we0u26yljzkrgnagvjafnq6hxfflxdcmmxdrudpw5kqv4nzmy",
                    "path": [
                    1852,
                    1815,
                    0
                    ],
                    "signType": "mnemonic"
                }
                ]
            },
            "settings": {
                "id": "xpub15ux84rpzhn8-pm",
                "networkId": "preprod",
                "name": "Tony in the air"
            }
        }"#.to_string();
        let password = "Minswap@123456".to_string();
        let wallet_name = "My MinWallet".to_string();
        let wallet = import_wallet(data, password, wallet_name).unwrap();
        assert_eq!(wallet.address, "addr_test1qqf2dhk96l2kq4xh2fkhwksv0h49vy9exw383eshppn863jereuqgh2zwxsedytve5gp9any9jwc5hz98sd47rwfv40stc26fr");
    }

    #[test]
    fn test_verify_password() {
        let phrase =
            "belt change crouch decorate advice emerge tongue loop cute olympic tuna donkey";
        let password = "123456";
        let wallet = create_wallet(
            phrase.to_string(),
            password.to_string(),
            "preprod".to_string(),
            "My MinWallet".to_string(),
        )
        .unwrap();
        let is_correct = verify_password(wallet, "Wrong Password".to_string());
        assert_eq!(is_correct, false);
    }
    #[test]
    fn test_change_password() {
        let phrase =
            "belt change crouch decorate advice emerge tongue loop cute olympic tuna donkey";
        let password = "123456";
        let wallet = create_wallet(
            phrase.to_string(),
            password.to_string(),
            "preprod".to_string(),
            "My MinWallet".to_string(),
        )
        .unwrap();
        let private_key_1 = wallet.get_private_key(password, 0).unwrap();

        let new_password = String::from("Minswap@123456");
        let new_wallet =
            change_password(wallet, password.to_string(), new_password.clone()).unwrap();
        let private_key_2 = new_wallet
            .get_private_key(new_password.as_str(), 0)
            .unwrap();
        assert_eq!(private_key_1.to_hex(), private_key_2.to_hex());
    }
    #[test]
    fn test_wallet_happy_case() {
        let phrase =
            "belt change crouch decorate advice emerge tongue loop cute olympic tuna donkey";
        let password = "123456";
        let wallet = create_wallet(
            phrase.to_string(),
            password.to_string(),
            "preprod".to_string(),
            "My MinWallet".to_string(),
        )
        .unwrap();
        assert_eq!(wallet.public_key, "2f676911d4c7c7a6fd1d44100ff057d9807badcff26d5dd758700f271988acb02f1b52e9302928cb7d7ee03b68a7c8dfba940b7100e8795fff75174e28137448");
        assert_eq!(wallet.address, "addr_test1qp5cpdqd3n6nuaa8rr8h20lnsxzx2uxdapknyh6fryl7e32e34tccc70arj2f4m9x9zdz4vu29rzzrtszalvqzpx625s2z2338".to_string());

        let prk = wallet.get_private_key(password, 0).unwrap();
        assert_eq!(prk.to_hex(), "28ceeb4ab29780c599235ceac57f28db9939ff722d71dd4ccae6298c06f4c9596bee62e48edf249344602b310231ba80883e1ecb4c7196d192af9ed48d9f9ad5");

        let tx_raw = "84a400d9010281825820b92cd85195fcf6bcbab09fbac22b0018a9aad5c7f75d85bcd4ed6538985f7f62020181825839006980b40d8cf53e77a718cf753ff381846570cde86d325f49193fecc5598d578c63cfe8e4a4d7653144d1559c5146210d70177ec00826d2a9821b00000001fa051528a3581cb4dac0cea6dcf6f951a07add2ef6114c41be3cb7b4cfddf06a2eb593a14c0014df104361707962617261191cbb581ce16c2dc8ae937e8d3790c7fd7168d7b994621ba14ca11415f39fed72a4434d494e1a0001c094444d494e7419c53e44744254431909134d0014df104341545448554841491b00000001ad9e7c03581ce4214b7cce62ac6fbba385d164df48e157eae5863521b4b67ca71d86a4582029acf586bf10c3b25c488705a542400178f9c9116f123a581d89fa8fb25ed3fb1a001d53d758203bb0079303c57812462dec9de8fb867cef8fd3768de7f12c77f6f0dd80381d0d1a00022098582044d75b06a5aafc296e094bf3a450734f739449c62183d4e3bbd50c28522afc971a00058bde58205efbe6716c317ee3a9333ca42993b2f9608a0e8a383e8b750312cf4d21970ab41a012318bc021a0002bda9031a04aae41da0f5f6";
        let tx = Transaction::from_hex(tx_raw).unwrap();
        let tx_hash = hash_transaction(&tx.body());
        assert_eq!(
            tx_hash.to_hex().as_str(),
            "7de67019c1ee101882736d4f7104f3bbeed33f0d16e30930c0f4b2f944872cff"
        );

        let witness = sign_tx(wallet, password.to_string(), 0, tx_raw.to_string()).unwrap();
        assert_eq!(witness.as_str(), "a100d9010281825820caef3384a369c8267801777c240bf648aa59719a31a3706113bd7cce67d477a45840e2987748dbb198c4ce6f7804a79cea2fe515e7d0730a18352394b6f8aac38d728a579a70ebcb9a0264069d139a1b911effc60e8b8c2513b690577292c8c3d80e");
    }

    #[test]
    fn test_wrong_password() {
        let phrase =
            "belt change crouch decorate advice emerge tongue loop cute olympic tuna donkey";
        let password = "123456";
        let wallet = create_wallet(
            phrase.to_string(),
            password.to_string(),
            "preprod".to_string(),
            "My MinWallet".to_string(),
        )
        .unwrap();
        assert_eq!(verify_password(wallet, "wrong_pass".to_string()), false);
    }
}
