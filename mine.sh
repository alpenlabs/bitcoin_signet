#!/bin/bash
source setup-mineto-address.sh

NBITS=${NBITS:-"1e0377ae"} #minimum difficulty in signet
ADDR=$(get_first_address)    # It will get the first address from the wallet ie. custom_signet

echo "Starting mining with address $ADDR"

# Initial mining of 100 blocks if blocks count is less than 100
BLOCKS_COUNT=$(bitcoin-cli -rpcwallet=custom_signet getblockcount)
if [[ $BLOCKS_COUNT -lt 100 ]]; then
    echo "Mining initial 100 blocks"
    for ((i = BLOCKS_COUNT; i <= 100; i++)); do
        echo "Minining initial block $i"
        miner --cli="bitcoin-cli -rpcwallet=custom_signet" generate --grind-cmd="bitcoin-util grind" --address=$ADDR --nbits=$NBITS --set-block-time=$(date +%s)
    done
else
    echo "Starting bitcoind mining from block $BLOCKS_COUNT"
fi


while true; do
    # Get address to receive miner reward.
    ADDR=$(get_next_address)
    if [[ -f "${BITCOIN_DIR}/BLOCKPRODUCTIONDELAY.txt" ]]; then
        BLOCKPRODUCTIONDELAY_OVERRIDE=$(cat ~/.bitcoin/BLOCKPRODUCTIONDELAY.txt)
        echo "Delay OVERRIDE before next block" $BLOCKPRODUCTIONDELAY_OVERRIDE "seconds."
        sleep $BLOCKPRODUCTIONDELAY_OVERRIDE
    else
        BLOCKPRODUCTIONDELAY=${BLOCKPRODUCTIONDELAY:="0"}
        if [[ BLOCKPRODUCTIONDELAY -gt 0 ]]; then
            echo "Delay before next block" $BLOCKPRODUCTIONDELAY "seconds."
            sleep $BLOCKPRODUCTIONDELAY
        fi
    fi
    echo "Mine To:" $ADDR
    # We must specify rpcwallet when multiple wallets are loaded
    miner --cli="bitcoin-cli -rpcwallet=custom_signet" generate --grind-cmd="bitcoin-util grind" --address=$ADDR --nbits=$NBITS --set-block-time=$(date +%s)
done