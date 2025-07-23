touch ${BITCOIN_DIR}/uses_modern_wallet
echo "Generate or import keyset"
gen-signet-keys.sh
SIGNETCHALLENGE=${SIGNETCHALLENGE:-$(cat ~/.bitcoin/SIGNETCHALLENGE.txt)}
if [[ -f "$BITCOIN_DIR/bitcoin.conf" ]]; then
  echo "Using existing bitcoin.conf from $BITCOIN_DIR"
else 
  echo "Generate bitcoind configuration"
  gen-bitcoind-conf.sh >${BITCOIN_DIR}/bitcoin.conf
fi
echo "Setup Signet"
setup-signet.sh

if [[ "$MINE_GENESIS" == "1" ]]; then
    echo "Mine Genesis Block"
    mine-genesis.sh
fi

touch ${BITCOIN_DIR}/install_done
