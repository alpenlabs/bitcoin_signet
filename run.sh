#!/bin/bash

# run bitcoind
bitcoind &

# Wait for bitcoind's RPC to actually be ready instead of a fixed `sleep 5`.
# At a large block index bitcoind needs well over 5s to start serving RPC, and
# the old fixed sleep let mine.sh start too early — its first `bitcoin-cli
# getnewaddress` failed, and mine.sh's `set -Eeuo pipefail` killed the mining
# loop while bitcoind stayed up = a silent miner halt (no pod restart).
#
# Use a bare `bitcoin-cli` (no -rpcconnect/-rpcport) so it reads the same
# mounted bitcoin.conf the node started with — exactly as mine.sh's bitcoin-cli
# calls do. Overriding the endpoint here would break deployments that mount a
# config with a non-default rpcport (the probe would loop forever).
echo "waiting for bitcoind RPC..."
until bitcoin-cli ping >/dev/null 2>&1; do
    sleep 2
done
echo "bitcoind RPC ready"

echo "get magic"
magic=$(cat /root/.bitcoin/signet/debug.log | grep -m1 magic)
magic=${magic:(-8)}
echo $magic > /root/.bitcoin/MAGIC.txt

# if in mining mode
if [[ "$MINERENABLED" == "1" ]]; then
    mine.sh
fi
