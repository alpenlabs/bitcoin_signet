#!/bin/bash
# This script creates n different wallets and addresses to receive miner reward.
# For generated n wallets, each will receive rewards in the order they are 
# specified in a `ADDRESS.txt` file.
# Index of reward receiving wallet for current round will be maintained in a `MINETO_IDX`
# text file.


DATADIR=${DATADIR:-~/.bitcoin}
# Number of wallets to create (you can change this)
NUM_WALLETS=${NUM_WALLETS:-5}

# CSV file to store wallet names and addresses
OUTPUT_FILE="$DATADIR/wallets.csv"
INDEX_FILE="$DATADIR/MINETO_IDX"

# Check if a wallet already exists
wallet_exists() {
    local wallet_name=$1
    if bitcoin-cli -datadir="$DATADIR" listwalletdir | grep -q "\"$wallet_name\""; then
        return 0 # Wallet exists
    else
        return 1 # Wallet does not exist
    fi
}

if [ ! -f "$OUTPUT_FILE" ]; then

    # Generate an address for custom_signet wallet which is used by sequencer
    # to add btc txs.
    ADDRESS=$(bitcoin-cli -datadir="$DATADIR" -rpcwallet="custom_signet" getnewaddress)

    # Add the custom_signet as our first address
    # This is needed for backward compatibility
    echo "custom_signet,$ADDRESS" > "$OUTPUT_FILE"
    
    # Create wallets, generate addresses, and store in CSV
    for ((i=1; i<=NUM_WALLETS; i++)); do
        WALLET_NAME="wallet_$i"
        if wallet_exists "$WALLET_NAME"; then
            echo "Wallet $WALLET_NAME already exists. Skipping..."
        else
            bitcoin-cli -datadir="$DATADIR" -named createwallet wallet_name="$WALLET_NAME" load_on_startup=true descriptors=false
        fi
        # Generate new address since we do not already have the wallets.csv 
        ADDRESS=$(bitcoin-cli -datadir="$DATADIR" -rpcwallet="$WALLET_NAME" getnewaddress)
        
        echo "$WALLET_NAME,$ADDRESS" >> "$OUTPUT_FILE"
        echo "Created wallet: $WALLET_NAME with address: $ADDRESS"
    done

    echo "All wallets created and addresses saved in $OUTPUT_FILE."
else
    echo "wallet list already exists"
fi



# Function to load addresses from the CSV file into an array
load_addresses() {
    addresses=()
    while IFS=',' read -r wallet address; do
        # Skip the header line
        if [[ "$wallet" != "wallet_name" ]]; then
            addresses+=("$address")
        fi
    done < "$OUTPUT_FILE"
}


# Initialize first address as the Mineto address
# Function to get the next address to receive mining rewards

get_next_address() {
    load_addresses

    # Check if the addresses array is empty
    if [ ${#addresses[@]} -eq 0 ]; then
        echo "Error: No addresses found in $OUTPUT_FILE"
        exit 1
    fi

    # Read the current index from the file, or initialize to 0 if not found
    if [ -f "$INDEX_FILE" ]; then
        current_index=$(cat "$INDEX_FILE")
    else
        current_index=0
    fi

    # Get the address at the current index
    next_address=${addresses[$current_index]}

    # Increment the index, wrapping around if necessary
    new_index=$(( (current_index + 1) % ${#addresses[@]} ))

    # Save the updated index back to the file
    echo "$new_index" > "$INDEX_FILE"

    # Return the next address
    echo "$next_address"
}
# echo "Next Address" $(get_next_address)

# get first address
get_first_address() {
    load_addresses
    echo ${addresses[0]}
}