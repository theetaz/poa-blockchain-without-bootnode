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