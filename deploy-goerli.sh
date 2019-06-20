#!/usr/bin/env bash

[[ -z $TMP_FILE ]] && {
  nonce=$(seth nonce "$ETH_FROM")
  TMP_FILE=$(mktemp /tmp/nonce.XXXXXX)
  echo "$nonce" > "$TMP_FILE"
  export TMP_FILE
}

# shellcheck source=lib/common.sh
. "${LIB_DIR:-$(cd "${0%/*}/lib"&&pwd)}/common.sh"
writeConfigFor "goerli"

test "$(seth chain)" == "goerli" || exit 1

# Set verify contract option in Etherscan if the API key is in the config file
# etherscanApiKey=$(jq -r ".etherscanApiKey" "$CONFIG_FILE")
# if [[ "$etherscanApiKey" != "" ]]; then
#     export DAPP_VERIFY_CONTRACT="yes"
#     export ETHERSCAN_API_KEY=$etherscanApiKey
# fi

"$LIBEXEC_DIR"/base-deploy

log "GOERLI DEPLOYMENT COMPLETED SUCCESSFULLY"
