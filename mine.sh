#!/bin/bash
source setup-mineto-address.sh

NBITS=${NBITS:-"1e0377ae"} #minimum difficulty in signet

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