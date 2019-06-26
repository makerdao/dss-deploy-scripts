#!/usr/bin/env bash

# Set fail flags
set -eo pipefail

# Set internal paths
BIN_DIR=${BIN_DIR:-$(cd "${BASH_SOURCE[0]%/*}/.."&&pwd)}
LIB_DIR=${LIB_DIR:-$BIN_DIR/lib}
LIBEXEC_DIR=${LIBEXEC_DIR:-$BIN_DIR/scripts}
CONFIG_DIR=${CONFIG_DIR:-$BIN_DIR}

DAPP_LIB=${DAPP_LIB:-$BIN_DIR/contracts}

# Declare functions

# arg: the name of the config file to write
writeConfigFor() {
    # Clean out directory
    rm -rf "$OUT_DIR" && mkdir "$OUT_DIR"
    # If environment variable exists bring the values from there, otherwise use the config file
    if [[ -n "$TDDS_CONFIG_VALUES" ]]; then
        echo "$TDDS_CONFIG_VALUES" > "$CONFIG_FILE"
    else
        cp "$CONFIG_DIR/deploy-$1.json" "$CONFIG_FILE"
    fi
}

# loads addresses as key-value pairs from $ADDRESSES_FILE and exports them as
# environment variables.
loadAddresses() {
    set +x
    local keys

    keys=$(jq -r "keys_unsorted[]" "$ADDRESSES_FILE")
    for KEY in $keys; do
        VALUE=$(jq -r ".$KEY" "$ADDRESSES_FILE")
        export "$KEY"="$VALUE"
    done
    set -x
}

addAddresses() {
    result=$(jq -s add "$ADDRESSES_FILE" /dev/stdin)
    printf %s "$result" > "$ADDRESSES_FILE"
}

copyAbis() {
    local lib; lib=$1
    mkdir -p "$OUT_DIR/abi"
    find "$DAPP_LIB/$lib/out" -name "*.abi" ! -name "*Test.abi" \
    -exec cp -f {} "$OUT_DIR/abi" \;
}

dappBuild() {
    [[ -n $DAPP_SKIP_BUILD ]] && return

    local lib; lib=$1
    (cd "$DAPP_LIB/$lib" || exit 1
        dapp "${@:2}" build
    )
}

dappCreate() {
    set -e
    local lib; lib=$1
    local class; class=$2
    DAPP_OUT="$DAPP_LIB/$lib/out" dapp create "$class" "${@:3}"
    copyAbis "$lib"
}

join() {
    local IFS=","
    echo "$*"
}

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() {
    printf '%b\n' "${GREEN}✓ ${1}${NC}"
}

err() {
    printf '%b\n' "${RED}❌${1}${NC}"
}

# Start verbose output
set -x

# Set exported variables
export ETH_GAS=7000000
unset SOLC_FLAGS

export OUT_DIR=${OUT_DIR:-$PWD/out}
ADDRESSES_FILE="$OUT_DIR/addresses.json"
export CONFIG_FILE="${OUT_DIR}/config.json"
