#[derive(Debug)]
pub enum NetworkId {
    Testnet = 0,
    Mainnet = 1,
}

impl NetworkId {
    pub fn from_network_environment(network_environment: &NetworkEnvironment) -> Self {
        match network_environment {
            NetworkEnvironment::Mainnet => NetworkId::Mainnet,
            NetworkEnvironment::Preprod => NetworkId::Testnet,
            NetworkEnvironment::Preview => NetworkId::Testnet,
        }
    }
}

#[derive(Debug, PartialEq)]
pub enum NetworkEnvironment {
    Mainnet = 764824073,
    Preprod = 1,
    Preview = 2,
}

impl NetworkEnvironment {
    pub fn to_network_id(&self) -> NetworkId {
        NetworkId::from_network_environment(self)
    }

    pub fn from_string(network: String) -> Option<NetworkEnvironment> {
        match network.to_lowercase().as_str() {
            "mainnet" => Some(NetworkEnvironment::Mainnet),
            "preprod" => Some(NetworkEnvironment::Preprod),
            "preview" => Some(NetworkEnvironment::Preview),
            _ => None,
        }
    }
}
