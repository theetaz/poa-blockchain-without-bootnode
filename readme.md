# Comprehensive Guide to Deploying a Proof of Authority (POA) Network Using Docker and Geth

This guide will help you deploy a Proof of Authority (POA) network using Docker and the Geth client. You can install the Geth client locally or use the Geth client Docker image. The Geth utility will help generate accounts and debug nodes.

## Installing Geth Client

### Installing Locally

1. **Download Geth**: Visit the [Geth website](https://geth.ethereum.org/downloads/) to download the appropriate version for your operating system.
2. **Install Geth**: Follow the installation instructions specific to your operating system.

### Using Docker Image

1. **Pull the Geth Docker Image**:
   ```bash
   docker pull ethereum/client-go:alltools-v1.13.13
   ```
2. **Run the Geth Docker Container**:
   ```bash
   docker run -it ethereum/client-go:alltools-v1.13.13
   ```

## Genesis.json File

The `genesis.json` file is crucial for setting up the blockchain network. It contains the initial configuration and state of the blockchain.

### Explanation of `genesis.json`

Here is a sample `genesis.json` file:

```json
{
  "config": {
    "chainId": <chain_id>,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "clique": {
      "period": <block_period>,
      "epoch": 30000
    }
  },
  "difficulty": "1",
  "gasLimit": "8000000",
  "extradata": "0x0000000000000000000000000000000000000000000000000000000000000000<initial_account_address_without_0x>0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
  "alloc": {
    "<initial_account_address>": { "balance": "300000" }
  }
}
```

#### Placeholder Values and Important Parameters

- **chainId**: A unique identifier for your blockchain network.
- **period**: The block time in seconds for the POA network.
- **extradata**: Contains the initial set of validators (addresses of the authority nodes) and padding.
- **alloc**: Pre-allocates funds to certain addresses.

### Creating the First Account

To create the first account, decide on the number of nodes for your network. For this example, we will use three nodes.

#### Selecting Node Counts

When selecting the number of nodes, consider:

- Network redundancy and reliability.
- Desired decentralization level.
- Performance requirements.

In this example, we will create three directories, one for each node:

- node1
- node2
- node3

Each directory will contain the following files:

- Dockerfile
- genesis.json
- password.txt
- keystore.txt
- start.sh

### Explanation of Each File

1. **Dockerfile**: Instructions to build the Docker image.
2. **genesis.json**: Configuration file for the blockchain network.
3. **password.txt**: Contains the password for the keystore.
4. **keystore.txt**: Contains the private key for the account.
5. **start.sh**: Script to initialize and start the node.

### Dockerfile

```dockerfile
FROM ethereum/client-go:alltools-v1.13.13

# Set the working directory in the container
WORKDIR /root

# Copy the required files into the container
COPY password.txt .
COPY genesis.json .
COPY keystore.txt .

# Install any needed packages
RUN apk add --no-cache bash curl jq

# Copy the startup script
COPY start.sh .
RUN chmod +x start.sh

# Expose the necessary ports
EXPOSE 8545 8552 30303

# Set the entrypoint to your startup script
ENTRYPOINT ["./start.sh"]
```

### genesis.json

```json
{
  "config": {
    "chainId": 1556,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "clique": {
      "period": 5,
      "epoch": 30000
    }
  },
  "difficulty": "1",
  "gasLimit": "8000000",
  "extradata": "0x0000000000000000000000000000000000000000000000000000000000000000b6944c53b2f51977a2a1a0330c29a1005d978a7e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
  "alloc": {
    "0xb6944c53b2f51977a2a1a0330c29a1005d978a7e": { "balance": "300000" }
  }
}
```

### keystore.txt

```json
{
  "address": "b6944c53b2f51977a2a1a0330c29a1005d978a7e",
  "crypto": {
    "cipher": "aes-128-ctr",
    "ciphertext": "4db99d60e424481fb5a36e6d54ff3b79172971ff127e38a328905300e4a66e90",
    "cipherparams": {
      "iv": "d2997bbddfb8fe0e08429dc63905b2bd"
    },
    "kdf": "scrypt",
    "kdfparams": {
      "dklen": 32,
      "n": 262144,
      "p": 1,
      "r": 8,
      "salt": "240f408cf1e965bb2f9a5fa2c25cc652b65937850397b30fc8b0b5e3268409d6"
    },
    "mac": "ebae663f766506f20c787a9b4228e66d9c63f0a5481fbab546ef02f25689ac17"
  },
  "id": "beaefa35-e73b-4907-b57d-906244a68007",
  "version": 3
}
```

### password.txt

The file contains the password for the keystore. Here is an example:

```text
yourpassword
```

### start.sh

```bash
#!/bin/bash

# Create the keystore directory
mkdir -p /root/.ethereum/keystore

# Copy the keystore file content
cat /root/keystore.txt > /root/.ethereum/keystore/key

# Extract the account address from keystore.txt
ACCOUNT=$(grep -o '"address":"[^"]*"' /root/keystore.txt | cut -d'"' -f4)
ACCOUNT="0x${ACCOUNT}"

# Initialize the node if it hasn't been initialized yet
if [ ! -d /root/.ethereum/geth ]; then
    geth --datadir /root/.ethereum init /root/genesis.json
fi

# Start the node
exec geth --datadir /root/.ethereum \
  --networkid 1556 \
  --nodiscover \
  --mine \
  --miner.etherbase "${ACCOUNT}" \
  --unlock "${ACCOUNT}" \
  --password /root/password.txt \
  --http.vhosts=* \
  --http \
  --http.addr "0.0.0.0" \
  --http.port "8545" \
  --http.corsdomain "*" \
  --http.api "admin,eth,web3,personal,net,miner,clique" \
  --allow-insecure-unlock \
  --authrpc.port "8552" \
  --port "30303" \
  --syncmode "full"
```

## Generating Keys and Updating `genesis.json`

### Generating Keys

To generate a new key using Geth, follow these steps for each node:

1. **Generate the Key**:

   ```bash
   geth account new --keystore <path_to_keystore_directory>
   ```

2. **Copy the Content of the Key File**:
   - Navigate to the keystore directory specified.
   - Open the newly created key file and copy its content.
   - Save this content in the `keystore.txt` file for the respective node.

#### Example for Node 1:

```bash
geth account new --keystore node1/keystore
```

- Copy the content of the newly created key file in `node1/keystore` into `node1/keystore.txt`.

Repeat the above steps for node2 and node3.

### Updating `genesis.json`

Navigate to the `node1/keystore.txt` file in there you will find the address of the account. Copy the address and replace the placeholder values in the `genesis.json` file.
make sure to update the key without the 0x prefix in the `extradata` field and with the 0x prefix in the `alloc` field.

1. **Update `genesis.json`**:
   - Replace `<initial_account_address_without_0x>` and `<initial_account_address>` in the `genesis.json` file with the extracted address from the initial node (node1).

### Why Not Add Other Keys to `genesis.json`?

By not adding the other keys to `genesis.json`, we maintain the flexibility to add or remove nodes as needed. This approach allows for easier scaling and management of the network. Nodes can be added dynamically using RPC endpoints without modifying the genesis block, which is immutable once the network is started.
