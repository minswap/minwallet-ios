use cardano_serialization_lib::{decrypt_with_password, encrypt_with_password};
use rand::Rng;

mod password_encryption_parameter {
    pub const SALT_SIZE: usize = 32;
    pub const NONCE_SIZE: usize = 12;
}

/// Generates a random value of the given size in hexadecimal format
fn generate_random_hex(size: usize) -> String {
    let mut rng = rand::thread_rng();
    (0..size)
        .map(|_| format!("{:02x}", rng.gen::<u8>()))
        .collect()
}

/// Generates a random salt
pub fn generate_salt() -> String {
    generate_random_hex(password_encryption_parameter::SALT_SIZE)
}

/// Generates a random nonce
pub fn generate_nonce() -> String {
    generate_random_hex(password_encryption_parameter::NONCE_SIZE)
}

pub fn encrypt_password(password: &str, data: &str) -> Option<String> {
    let salt = generate_salt();
    let nonce = generate_nonce();
    let password_hex = hex::encode(password);
    match encrypt_with_password(&password_hex, &salt, &nonce, &data) {
        Ok(v) => Some(v),
        Err(_) => None,
    }
}

pub fn decrypt_password(password: &str, data: &str) -> Option<String> {
    let password_hex = hex::encode(password);
    match decrypt_with_password(&password_hex, &data) {
        Ok(v) => Some(v),
        Err(_) => None,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_round_trip_encryption() {
        let password = "fMESeaTVyCklzUD";
        let data = String::from("736f6d65206461746120746f20656e6372797074");
        let encrypted_data = encrypt_password(&password, &data).unwrap();
        let decrypted_data = decrypt_password(&password, &encrypted_data).unwrap();
        assert_eq!(data, decrypted_data);
    }
}
