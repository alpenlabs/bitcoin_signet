BITCOIN_DIR="${BITCOIN_DIR:-/root/.bitcoin}"
BITCOIN_CONF="$BITCOIN_DIR/bitcoin.conf"
TMP_CONF="$BITCOIN_DIR/bitcoin.conf.tmp"

# Replace or insert rpcuser/rpcpassword based on env vars
patch_rpc_credentials() {
  echo "🔐 Patching bitcoin.conf with correct RPC credentials..."

  cp "$BITCOIN_CONF" "$TMP_CONF"

  # Patch rpcuser
  if grep -q "^rpcuser=" "$TMP_CONF"; then
    sed -i "s/^rpcuser=.*/rpcuser=$RPCUSER/" "$TMP_CONF"
  else
    echo "rpcuser=$RPCUSER" >> "$TMP_CONF"
  fi

  # Patch rpcpassword
  if grep -q "^rpcpassword=" "$TMP_CONF"; then
    sed -i "s/^rpcpassword=.*/rpcpassword=$RPCPASSWORD/" "$TMP_CONF"
  else
    echo "rpcpassword=$RPCPASSWORD" >> "$TMP_CONF"
  fi

  # Overwrite original with patched file
  cat "$TMP_CONF" > "$BITCOIN_CONF"
  rm -f "$TMP_CONF"
}
