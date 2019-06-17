#!/usr/bin/env bash

# shellcheck source=lib/common.sh
. "${LIB_DIR:-$(cd "${0%/*}/lib"&&pwd)}/common.sh"
writeConfigFor "kovan"

if [[ "$CONFIG_STEP" == "kovan" ]]; then
    test "$(seth chain)" == "kovan" || exit 1
    # Set verify contract option in Etherscan if the API key is in the config file
    etherscanApiKey=$(jq -r ".etherscanApiKey" "$CONFIG_FILE")
    if [[ "$etherscanApiKey" != "" ]]; then
        export DAPP_VERIFY_CONTRACT="yes"
        export ETHERSCAN_API_KEY=$etherscanApiKey
    fi
fi


"$LIBEXEC_DIR"/base-deploy

log "KOVAN DEPLOYMENT COMPLETED SUCCESSFULLY"
