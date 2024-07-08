# Comprehensive Guide to Deploying a Proof of Authority (POA) Network Using Docker and Geth

This guide will help you deploy a Proof of Authority (POA) network using Docker and the Geth client. You can install the Geth client locally or use the Geth client Docker image. The Geth utility will help generate accounts and debug nodes.

## Table of Contents

- [Comprehensive Guide to Deploying a Proof of Authority (POA) Network Using Docker and Geth](#comprehensive-guide-to-deploying-a-proof-of-authority-poa-network-using-docker-and-geth)
  - [Table of Contents](#table-of-contents)
  - [Installing Geth Client](#installing-geth-client)
    - [Installing Locally](#installing-locally)
    - [Using Docker Image](#using-docker-image)
  - [Genesis.json File](#genesisjson-file)
    - [Explanation of `genesis.json`](#explanation-of-genesisjson)
      - [Placeholder Values and Important Parameters](#placeholder-values-and-important-parameters)
    - [Creating the First Account](#creating-the-first-account)
      - [Selecting Node Counts](#selecting-node-counts)
  - [Setting Up Nodes](#setting-up-nodes)
    - [Node Directories and Files](#node-directories-and-files)
    - [Explanation of Each File](#explanation-of-each-file)
      - [Dockerfile](#dockerfile)
      - [genesis.json](#genesisjson)
      - [keystore.txt](#keystoretxt)
      - [password.txt](#passwordtxt)
      - [start.sh](#startsh)
  - [Generating Keys and Updating `genesis.json`](#generating-keys-and-updating-genesisjson)
    - [Generating Keys](#generating-keys)
      - [Example for Node 1:](#example-for-node-1)
    - [Updating `genesis.json`](#updating-genesisjson)
    - [Why Not Add Other Keys to `genesis.json`?](#why-not-add-other-keys-to-genesisjson)
  - [Building and Running Nodes](#building-and-running-nodes)
    - [Building the Docker Image](#building-the-docker-image)
    - [Running the Docker Container](#running-the-docker-container)
  - [Connecting Nodes](#connecting-nodes)
    - [Retrieving Enode URLs](#retrieving-enode-urls)
    - [Adding Enode URLs to Nodes](#adding-enode-urls-to-nodes)
    - [Verifying Connection](#verifying-connection)
  - [Proposing Signers](#proposing-signers)
    - [Confirming Signer Addition](#confirming-signer-addition)

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

## Setting Up Nodes

### Node Directories and Files

Create directories for each node and include the following files in each:

1. **Dockerfile**: Instructions to build the Docker image.
2. **genesis.json**: Configuration file for the blockchain network.
3. **password.txt**: Contains the password for the keystore.
4. **keystore.txt**: Contains the private key for the account.
5. **start.sh**: Script to initialize and start the node.

### Explanation of Each File

#### Dockerfile

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

#### genesis.json

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

#### keystore.txt

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

#### password.txt

The file contains the password for the keystore. Here is an example:

```text
yourpassword
```

#### start.sh

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
  --http

.corsdomain "*" \
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

Navigate to the `node1/keystore.txt` file, where you will find the address of the account. Copy the address and replace the placeholder values in the `genesis.json` file. Make sure to update the key without the `0x` prefix in the `extradata` field and with the `0x` prefix in the `alloc` field.

1. **Update `genesis.json`**:
   - Replace `<initial_account_address_without_0x>` and `<initial_account_address>` in the `genesis.json` file with the extracted address from the initial node (node1).

### Why Not Add Other Keys to `genesis.json`?

By not adding the other keys to `genesis.json`, we maintain the flexibility to add or remove nodes as needed. This approach allows for easier scaling and management of the network. Nodes can be added dynamically using RPC endpoints without modifying the genesis block, which is immutable once the network is started.

## Building and Running Nodes

After setting up the necessary files and generating the keys, follow these steps to build and run each node.

### Building the Docker Image

Navigate to each node's directory and build the Docker image:

```bash
docker build -t <node_name> .
```

Replace `<node_name>` with a unique name for each node (e.g., `node1`, `node2`, `node3`).

### Running the Docker Container

Run the Docker container for each node:

```bash
docker run -d --name <container_name> -p 8545:8545 -p 8552:8552 -p 30303:30303 <node_name>
```

Replace `<container_name>` with a unique name for each container (e.g., `node1_container`, `node2_container`, `node3_container`).

## Connecting Nodes

To connect the nodes, retrieve the enode URLs from each node and add them to each other's configuration.

### Retrieving Enode URLs

To retrieve the enode URL of a node, use the following command:

```bash
docker exec -it <container_name> geth attach --exec admin.nodeInfo.enode
```

### Adding Enode URLs to Nodes

Add the retrieved enode URLs to the other nodes to ensure redundancy and resilience. For instance, if you have three nodes (node1, node2, and node3), add the enode URLs as follows:

1. **Add Node1 and Node3 Enode URLs to Node2**:

   ```bash
   docker exec -it node2_container geth attach --exec "admin.addPeer('<enode_url_node1>')"
   docker exec -it node2_container geth attach --exec "admin.addPeer('<enode_url_node3>')"
   ```

2. **Add Node2 and Node3 Enode URLs to Node1**:

   ```bash
   docker exec -it node1_container geth attach --exec "admin.addPeer('<enode_url_node2>')"
   docker exec -it node1_container geth attach --exec "admin.addPeer('<enode_url_node3>')"
   ```

3. **Add Node1 and Node2 Enode URLs to Node3**:

   ```bash
   docker exec -it node3_container geth attach --exec "admin.addPeer('<enode_url_node1>')"
   docker exec -it node3_container geth attach --exec "admin.addPeer('<enode_url_node2>')"
   ```

### Verifying Connection

You can verify the connection by checking the peers of each node:

```bash
docker exec -it <container_name> geth attach --exec admin.peers
```

## Proposing Signers

To propose new signers dynamically, retrieve the account address from the `keystore.txt` file of each node and use the following command:

```bash
docker exec -it <container_name> geth attach --exec "clique.propose('<account_address>', true)"
```

Replace `<account_address>` with the account address of the node you want to add as a signer.

### Confirming Signer Addition

You can confirm the addition of signers by checking the list of signers:

```bash
docker exec -it <container_name> geth attach --exec clique.getSigners()
```

By following these steps, you should be able to set up, connect, and manage a POA network using Docker and Geth. The nodes will sync and mine blocks, and you can dynamically add signers as needed.
