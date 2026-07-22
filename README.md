# Bitcoin Signet Docker Image

## 📌 Table of Contents

- [Bitcoin Signet Docker Image](#bitcoin-signet-docker-image)
  - [📌 Table of Contents](#-table-of-contents)
  - [🔍 Overview](#-overview)
  - [🛠 Environment Variables](#-environment-variables)
    - [⛏ Mining Configuration:](#-mining-configuration)
    - [🌐 RPC Configuration:](#-rpc-configuration)
    - [🌍 Network Configuration:](#-network-configuration)
    - [📡 ZMQ Configuration:](#-zmq-configuration)
    - [🔧 Additional Configuration:](#-additional-configuration)
  - [🚀 Building and Running the Docker Image](#-building-and-running-the-docker-image)
  - [🔧 Docker Commands](#-docker-commands)
  - [📜 License](#-license)

---

## 🔍 Overview

Bitcoin Signet provides a sandboxed environment for Bitcoin, allowing developers and testers to simulate the Bitcoin network without the risks associated with the main or test networks. This Docker image facilitates the deployment and configuration of a Signet node, offering a range of customizable options through environment variables.

Versions prior to 29.0 were using BDB wallet, system will automaticly update your wallet to new descriptor format.
`PRIVKEY` prior to 29.0 was a WIF, now is descriptor on new wallets. 

## 🛠 Environment Variables

### ⛏ Mining Configuration:

- `MNEMONIC`(Required): Mnemonic is used instead of `PRIVKEY`.
- `BLOCKPRODUCTIONDELAY`: Sleep period between mining blocks. Defaults to a specified value. (**mining mode only**)
  - If `~/.bitcoin/BLOCKPRODUCTIONDELAY.txt` is present, this value will be used, allowing dynamic changes.
- `MINERENABLED`: Flag to enable the mining chain. (**mining mode only**)
- `NBITS`: Sets the minimum difficulty in mining. (**mining mode only**)
- `MINETO`: Address to mine to. If not provided, a new address will be generated for each block. (**mining mode only**)
- `SIGNETCHALLENGE`: Sets the valid block producer for this Signet. Required for client-mode.
- If `MINERENABLED=1` and not provided, it will be generated. 
- `MINE_GENESIS`: set to 1 if you are starting a new chain, will mine first block so passes `CHAIN_TIP_AGE` check.

### 🌐 RPC Configuration:

- `RPCUSER`: bitcoind RPC User.
- `RPCPASSWORD`: bitcoind RPC password.
- `RPCTHREADS`: # of work threads (default 16)
- `RPCSERVERTIMEOUT`: RPC timeout (default 600s)
- `RPCWORKQUEUE`: RPC queue lenght (50)
 
### 🌍 Network Configuration:

- `ONIONPROXY`: Tor SOCK5 endpoint.
- `TORPASSWORD`: Tor control port password.
- `TORCONTROL`: Tor control port endpoint.
- `I2PSAM`: I2P control endpoint.
- `UACOMMENT`: UA Comment displayed on `bitcoin-cli -netinfo` printout.

### 📡 ZMQ Configuration:

- `ZMQPUBRAWBLOCK`: bitcoind setting.
- `ZMQPUBRAWTX`: bitcoind setting.
- `ZMQPUBHASHBLOCK`: bitcoind setting.

### 🔧 Additional Configuration:

- `RPCBIND`: bitcoind setting.
- `RPCALLOWIP`: bitcoind setting.
- `WHITELIST`: bitcoind setting.
- `ADDNODE`: Add seeding node location. Use comma-separation for multiple nodes. Needed for client-mode.
- `EXTERNAL_IP`: Add public IP/onion endpoint information. Use comma-separation for multiple IPs.

## 🚀 Building and Running the Docker Image

1. **Building the Docker Image**:

   ```bash
   docker build -t bitcoin-signet .
   ```

   Multi-arch (`linux/amd64` + `linux/arm64`) build via buildx:

   ```bash
   docker buildx build --platform linux/amd64,linux/arm64 -t bitcoin-signet .
   ```

   The `Dockerfile` selects the matching `bitcoind` binary tarball from bitcoincore.org based on `TARGETPLATFORM`, so both architectures build from the same source without changes.

2. **Pre-built Image**:

   Multi-arch images are published to GHCR on every push to `main` and on every `v*` tag:

   ```bash
   docker pull ghcr.io/alpenlabs/bitcoin_signet:latest
   ```

3. **Running the Docker Image**:
   ```bash
   docker run -d --name bitcoin-signet-instance bitcoin-signet
   ```

**Note**: Ensure you have Docker installed and running on your machine before executing the above commands. Adjust configurations as needed for your specific use case.

## 🔧 Docker Commands

To make the most out of the Bitcoin Signet Docker image, here are some essential Docker commands:

1. **View running containers**:

   ```bash
   docker ps
   ```

2. **View all containers (including stopped ones)**:

   ```bash
   docker ps -a
   ```

3. **Stop a running container**:

   ```bash
   docker stop bitcoin-signet-instance
   ```

4. **Start a stopped container**:

   ```bash
   docker start bitcoin-signet-instance
   ```

5. **Remove a container**:

   ```bash
   docker rm bitcoin-signet-instance
   ```

6. **View logs of a container**:

   ```bash
   docker logs bitcoin-signet-instance
   ```

7. **Execute a command inside a running container**:

   ```bash
   docker exec -it bitcoin-signet-instance /bin/bash
   ```

8. **Pull the latest version of the image**:

   ```bash
   docker pull bitcoin-signet
   ```

9. **Remove an image**:

   ```bash
   docker rmi bitcoin-signet
   ```

10. **View all Docker images**:
    ```bash
    docker images
    ```

Remember to replace `bitcoin-signet-instance` with the name of your container if you've named it differently.

## 📜 License

This project is licensed under the terms of the [MIT License](./LICENSE).
