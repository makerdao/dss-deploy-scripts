#!/usr/bin/env bash

# Set fail flags
set -eo pipefail

DAPP_LIB=${DAPP_LIB:-$BIN_DIR/contracts}

# Declare functions

# arg: the name of the config file to write
writeConfigFor() {
    # Clean out directory
    rm -rf "$OUT_DIR" && mkdir "$OUT_DIR"
    # If config file is passed via param used that one
    if [[ -n "$CONFIG" ]]; then
        cp "$CONFIG" "$CONFIG_FILE"
    # If environment variable exists bring the values from there
    elif [[ -n "$TDDS_CONFIG_VALUES" ]]; then
        echo "$TDDS_CONFIG_VALUES" > "$CONFIG_FILE"
    # otherwise use the default config file
    else
        cp "$CONFIG_DIR/$1.json" "$CONFIG_FILE"
    fi
}

# loads addresses as key-value pairs from $ADDRESSES_FILE and exports them as
# environment variables.
loadAddresses() {
    local keys

    keys=$(jq -r "keys_unsorted[]" "$ADDRESSES_FILE")
    for KEY in $keys; do
        VALUE=$(jq -r ".$KEY" "$ADDRESSES_FILE")
        export "$KEY"="$VALUE"
    done
}

addAddresses() {
    result=$(jq -s add "$ADDRESSES_FILE" /dev/stdin)
    printf %s "$result" > "$ADDRESSES_FILE"
}

copyAbis() {
    local lib; lib=$1
    mkdir -p "$OUT_DIR/abi"
    find "$DAPP_LIB/$lib/out" \
        -name "*.abi" ! -name "*Test.abi" ! -name "*Like.abi" ! -name "*DSNote.abi" ! -name "*FakeUser.abi" ! -name "*Hevm.abi" \
        -exec cp -f {} "$OUT_DIR/abi" \;
}

copyBins() {
    local lib; lib=$1
    local DIR; DIR="$OUT_DIR/bin"
    if [[ $(isOptimized "$1") == "optimized" ]]; then
        DIR="$DIR/optimized"
    fi

    mkdir -p "$DIR"
    find "$DAPP_LIB/$lib/out" \
        -name "*.bin" ! -name "*Test.bin" ! -name "*Like.bin" ! -name "*DSNote.bin" ! -name "*FakeUser.bin" ! -name "*Hevm.bin" \
        -exec cp -f {} "$DIR" \;
    find "$DAPP_LIB/$lib/out" \
        -name "*.bin-runtime" ! -name "*Test.bin-runtime" ! -name "*Like.bin-runtime" ! -name "*DSNote.bin-runtime" ! -name "*FakeUser.bin-runtime" ! -name "*Hevm.bin-runtime"  \
        -exec cp -f {} "$DIR" \;
}

copyMeta() {
    local lib; lib=$1
    local DIR; DIR="$OUT_DIR/meta"
    if [[ $(isOptimized "$1") == "optimized" ]]; then
        DIR="$DIR/optimized"
    fi

    mkdir -p "$DIR"
    find "$DAPP_LIB/$lib/out" \
        -name "*_meta.json" ! -name "*Test_meta.json" ! -name "*Like_meta.json" ! -name "*DSNote_meta.json" ! -name "*FakeUser_meta.json" ! -name "*Hevm_meta.json" \
        -exec cp -f {} "$DIR" \;
}

copy() {
    local lib; lib=$1
    copyAbis "$lib"
    copyBins "$lib"
    copyMeta "$lib"
}

isOptimized() {
    local val; val=$1
    local i; i=$((${#val}-1))
    echo "${val:$i-8:10}"
}

dappCreate() {
    set -e
    local lib; lib=$1
    local class; class=$2
    DAPP_OUT="$DAPP_LIB/$lib/out" dapp create "$class" "${@:3}"
    copy "$lib"
}

sethSend() {
    set -e
    echo "seth send $*"
    seth send "$@"
    echo ""
}

join() {
    local IFS=","
    echo "$*"
}

GREEN='\033[0;32m'
NC='\033[0m' # No Color

log() {
    printf '%b\n' "${GREEN}${1}${NC}"
    echo ""
}

# Start verbose output
# set -x

# Set exported variables
export ETH_GAS=7000000
unset SOLC_FLAGS

export OUT_DIR=${OUT_DIR:-$PWD/out}
ADDRESSES_FILE="$OUT_DIR/addresses.json"
export CONFIG_FILE="${OUT_DIR}/config.json"
