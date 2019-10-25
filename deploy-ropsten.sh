#!/usr/bin/env bash

# shellcheck source=lib/common.sh
. "${LIB_DIR:-$(cd "${0%/*}/lib"&&pwd)}/common.sh"
writeConfigFor "ropsten"

test "$(seth chain)" == "ropsten" || exit 1

# Set verify contract option in Etherscan if the API key is in the config file
# etherscanApiKey=$(jq -r ".etherscanApiKey" "$CONFIG_FILE")
# if [[ "$etherscanApiKey" != "" ]]; then
#     export DAPP_VERIFY_CONTRACT="yes"
#     export ETHERSCAN_API_KEY=$etherscanApiKey
# fi

export DEPLOY_RESTRICTED_FAUCET="no"
"$LIBEXEC_DIR"/base-deploy

log "ROPSTEN DEPLOYMENT COMPLETED SUCCESSFULLY"
