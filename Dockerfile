FROM debian:bookworm-slim as builder

ARG BITCOIN_VERSION=${BITCOIN_VERSION:-29.0}
ARG TARGETPLATFORM 

RUN  apt-get update && \
     apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu wget libc6 procps python3
WORKDIR /tmp
RUN case $TARGETPLATFORM in \
  linux/amd64) \
  echo "amd64" && export TRIPLET="x86_64-linux-gnu";; \
  linux/arm64) \
  echo "arm64" && export TRIPLET="aarch64-linux-gnu";; \
  esac && \
  BITCOIN_URL="https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-${TRIPLET}.tar.gz" && \
  BITCOIN_FILE="bitcoin-${BITCOIN_VERSION}-${TRIPLET}.tar.gz" && \
  wget -qO "${BITCOIN_FILE}" "${BITCOIN_URL}" && \
  mkdir -p bin && \
  tar -xzvf "${BITCOIN_FILE}" -C /tmp/bin --strip-components=2 "bitcoin-${BITCOIN_VERSION}/bin/bitcoin-cli" "bitcoin-${BITCOIN_VERSION}/bin/bitcoind" "bitcoin-${BITCOIN_VERSION}/bin/bitcoin-wallet" "bitcoin-${BITCOIN_VERSION}/bin/bitcoin-util" 

FROM rust:1.83 as custom-signet-bitcoin

LABEL org.opencontainers.image.authors="NBD"
LABEL org.opencontainers.image.licenses=MIT
LABEL org.opencontainers.image.source="https://github.com/nbd-wtf/bitcoin_signet"

ENV BITCOIN_DIR=/root/.bitcoin 

ENV NBITS=${NBITS}
ENV SIGNETCHALLENGE=${SIGNETCHALLENGE}
ENV MNEMONIC=${MNEMONIC:? Please set MNEMONIC env var}
ENV CHAIN_TIP_AGE=${CHAIN_TIP_AGE:-"0"}
ENV MINE_GENESIS=${MINE_GENESIS:-"0"}
ENV RPCUSER=${RPCUSER:-"bitcoin"}
ENV RPCPASSWORD=${RPCPASSWORD:-"bitcoin"}
ENV COOKIEFILE=${COOKIEFILE:-"false"}
ENV ONIONPROXY=${ONIONPROXY:-""}
ENV TORPASSWORD=${TORPASSWORD:-""}
ENV TORCONTROL=${TORCONTROL:-""}
ENV I2PSAM=${I2PSAM:-""}

ENV UACOMMENT=${UACOMMENT:-"CustomSignet"}
ENV ZMQPUBHASHBLOCK=${ZMQPUBHASHBLOCK:-"tcp://0.0.0.0:28332"}
ENV ZMQPUBHASHTX=${ZMQPUBRAWTX:-"tcp://0.0.0.0:28333"}
ENV ZMQPUBRAWBLOCK=${ZMQPUBRAWBLOCK:-"tcp://0.0.0.0:28334"}
ENV ZMQPUBRAWTX=${ZMQPUBRAWTX:-"tcp://0.0.0.0:28335"}
ENV ZMQPUBSEQUENCE=${ZMQPUBSEQUENCE:-"tcp://0.0.0.0:28336"}

ENV RPCBIND=${RPCBIND:-"0.0.0.0:38332"}
ENV RPCALLOWIP=${RPCALLOWIP:-"0.0.0.0/0"}
ENV WHITELIST=${WHITELIST:-"0.0.0.0/0"}
ENV ADDNODE=${ADDNODE:-""}
ENV BLOCKPRODUCTIONDELAY=${BLOCKPRODUCTIONDELAY:-""}
ENV MINERENABLED=${MINERENABLED:-"1"}
ENV MINETO=${MINETO:-""}
ENV EXTERNAL_IP=${EXTERNAL_IP:-""} 
ENV RPCTHREADS=${RPCTHREADS:-"16"}
ENV RPCSERVERTIMEOUT=${RPCSERVERTIMEOUT:-"600"}
ENV RPCWORKQUEUE=${RPCWORKQUEUE:-"50"} 

VOLUME $BITCOIN_DIR
EXPOSE 28332 28333 28334 38332 38333 38334
RUN  apt-get update && \
     apt-get install -qq --no-install-recommends procps python3-dev python3-pip jq gcc && \
     apt-get clean
COPY --from=builder "/tmp/bin" /usr/local/bin 
COPY docker-entrypoint.sh /usr/local/bin/entrypoint.sh
COPY miner_imports /usr/local/bin
COPY miner /usr/local/bin/miner
COPY *.sh /usr/local/bin/
COPY rpcauth.py /usr/local/bin/rpcauth.py
COPY mnemonic-to-descriptor.py /usr/local/bin/mnemonic-to-descriptor.py

RUN pip3 install  --break-system-packages  setuptools
RUN pip3 install  --break-system-packages  bip_utils

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["run.sh"]
