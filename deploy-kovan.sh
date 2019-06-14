#!/usr/bin/env bash

# shellcheck source=lib/common.sh
. "${LIB_DIR:-$(cd "${0%/*}/lib"&&pwd)}/common.sh"
writeConfigFor "kovan"

test "$(seth chain)" == "kovan" || exit 1

# Set verify contract option in Etherscan if the API key is in the config file
etherscanApiKey=$(jq -r ".etherscanApiKey" "$CONFIG_FILE")
if [[ "$etherscanApiKey" != "" ]]; then
    export DAPP_VERIFY_CONTRACT="yes"
    export ETHERSCAN_API_KEY=$etherscanApiKey
fi

tokens=$(jq -r ".tokens | keys_unsorted[]" "$CONFIG_FILE")
for token in $tokens; do
    eval "export PIP_${token}=$(jq -r ".tokens.${token} | .pip" "$CONFIG_FILE")"
done

"$LIBEXEC_DIR"/base-deploy

"$LIBEXEC_DIR"/poll-deploy

"$LIBEXEC_DIR"/set-ilks-mat

setLinesMode=$(jq -r ".setLinesMode" "$CONFIG_FILE")
if [[ $setLinesMode = "direct" ]]; then
    "$LIBEXEC_DIR"/set-ilks-line
elif [[ $setLinesMode = "vote" ]]; then
    "$LIBEXEC_DIR"/set-ilks-spell-line
fi

"$LIBEXEC_DIR"/set-ilks-duty

"$LIBEXEC_DIR"/set-ilks-pip-whitelist

"$LIBEXEC_DIR"/set-ilks-spotter-poke

"$LIBEXEC_DIR"/set-ilks-chop

"$LIBEXEC_DIR"/set-ilks-lump

"$LIBEXEC_DIR"/set-ilks-beg

"$LIBEXEC_DIR"/set-ilks-ttl

"$LIBEXEC_DIR"/set-ilks-tau

"$LIBEXEC_DIR"/set-pause-auth-delay

log "KOVAN DEPLOYMENT COMPLETED SUCCESSFULLY"
