use cardano_serialization_lib::{TransactionBody, TransactionHash};
use cryptoxide::blake2b::Blake2b;

pub(crate) fn blake2b256(data: &[u8]) -> [u8; 32] {
    let mut out = [0; 32];
    Blake2b::blake2b(&mut out, data, &[]);
    out
}

#[allow(dead_code)]
// Testing Purpose Only
pub fn hash_transaction(tx_body: &TransactionBody) -> TransactionHash {
    TransactionHash::from(blake2b256(tx_body.to_bytes().as_ref()))
}
