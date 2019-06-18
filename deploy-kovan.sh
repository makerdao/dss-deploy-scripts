#!/usr/bin/env bash

# shellcheck source=lib/common.sh
. "${LIB_DIR:-$(cd "${0%/*}/lib"&&pwd)}/common.sh"
setConfigFile "kovan"

test "$(seth chain)" == "kovan" || exit 1

# Set verify contract option in Etherscan if the API key is in the config file
etherscanApiKey=$(jq -r ".etherscanApiKey" "$CONFIG_FILE")
if [[ "$etherscanApiKey" != "" ]]; then
    export DAPP_VERIFY_CONTRACT="yes"
    export ETHERSCAN_API_KEY=$etherscanApiKey
fi

"$LIBEXEC_DIR"/base-deploy

echo "KOVAN DEPLOYMENT COMPLETED SUCCESSFULLY"
