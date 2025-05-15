
bitcoind -datadir=$BITCOIN_DIR --daemonwait -persistmempool #-deprecatedrpc=create_bdb
# use the new descriptors for signet challenge
bitcoin-cli -datadir=$BITCOIN_DIR -named createwallet wallet_name="custom_signet" load_on_startup=true descriptors=true blank=true
bitcoin-cli -datadir=$BITCOIN_DIR importdescriptors "$(mnemonic-to-descriptor.py "$MNEMONIC" --runner "bitcoin-cli -datadir=$BITCOIN_DIR")" 2>&1 > /dev/null
