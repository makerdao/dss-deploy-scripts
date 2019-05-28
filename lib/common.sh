#!/usr/bin/env bash

# Set fail flags
set -eo pipefail

BIN_DIR=${BIN_DIR:-$(cd "${BASH_SOURCE[0]%/*}/.."&&pwd)}
LIB_DIR=${LIB_DIR:-$BIN_DIR/lib}
LIBEXEC_DIR=${LIBEXEC_DIR:-$BIN_DIR/scripts}
CONFIG_DIR=${CONFIG_DIR:-$BIN_DIR}

DAPP_LIB=${DAPP_LIB:-$BIN_DIR/contracts}

export OUT_DIR=${OUT_DIR:-$PWD/out}

export ETH_GAS=7000000
unset SOLC_FLAGS

export CONFIG_FILE="${OUT_DIR}/config.json"

setConfigStep() {
    CONFIG_STEP=${CONFIG_STEP:-"$1"}

    # Only executes if called from the initial script
    if [[ "$CONFIG_STEP" == "$1" ]]; then
        # Clean out directory
        rm -rf "$OUT_DIR" && mkdir "$OUT_DIR"
        # If environment variable exists bring the values from there, otherwise use the config file
        if [[ -n "$TDDS_CONFIG_VALUES" ]]; then
            echo "$TDDS_CONFIG_VALUES" > "$CONFIG_FILE"
        else
            cp "$CONFIG_DIR/$CONFIG_STEP.json" "$CONFIG_FILE"
        fi
    fi
    echo "$CONFIG_STEP"
}

loadAddresses() {
    local keys

    keys=$(jq -r "keys_unsorted[]" "$OUT_DIR/addresses.json")
    for KEY in $keys; do
        VALUE=$(jq -r ".$KEY" "$OUT_DIR/addresses.json")
        eval "export $KEY=$VALUE"
    done
}

addAddresses() {
    result=$(jq -s add "$OUT_DIR/addresses.json" /dev/stdin)
    printf %s "$result" > "$OUT_DIR/addresses.json"
}

dappBuild() {
  test -n "$SKIP_BUILD" && return

  local lib; lib=$1
  (cd "$DAPP_LIB/$lib" || exit 1
    dapp "${@:2}" build
  )
}

dappCreate() {
  local lib; lib=$1
  local class; class=$2
  DAPP_OUT="$DAPP_LIB/$lib/out" dapp create "$class" "${@:3}"
#   mkdir -p "$OUT_DIR/abi"
#   cp "$DAPP_LIB/$lib/out/$class.abi" "$OUT_DIR/abi"
}

# Start verbose output
set -x
