#!/bin/bash
set -eo pipefail

# source patch-creds.sh
source utils.sh

shutdown_gracefully(){

  echo "Container is shutting down, lets make sure bitcoind flushes the db."
  bitcoin-cli stop
  sleep 5
}
trap shutdown_gracefully SIGTERM SIGHUP SIGQUIT SIGINT

mkdir -p "${BITCOIN_DIR}" 
# check if this is first run if so run init if config
if [[ ! -f "${BITCOIN_DIR}/install_done" ]]; then
  echo "install_done file not found, running install.sh."
  install.sh #this is config based on args passed into mining node or peer.
else
  echo "install_done file exists, skipping setup process."
  
  SIGNETCHALLENGE=${SIGNETCHALLENGE:-$(cat ~/.bitcoin/SIGNETCHALLENGE.txt)}
  BITCOIN_CONF="$BITCOIN_DIR/bitcoin.conf"
  if [[ -f "$BITCOIN_CONF" ]]; then
    echo "📄 Found mounted bitcoin.conf"
    # assert that the challenges match, if not exit with proper message.
    # This assertion is called only after ensuring both files (bitcoin.conf, SIGNETCHALLENGE.txt) exist.
    if ! assert_signetchallenge_match; then
      echo "Exiting due to signetchallenge mismatch or missing config."
      exit 1
    fi
  else 
    echo "Generate bitcoind configuration"
    gen-bitcoind-conf.sh >${BITCOIN_DIR}/bitcoin.conf
  fi
fi

$@ &
echo "Infinite loop"
while true
do
  tail -f /dev/null & wait ${!}
done
