#!/usr/bin/env bash

[[ -z $TMP_FILE ]] && {
  nonce=$(seth nonce "$ETH_FROM")
  TMP_FILE=$(mktemp /tmp/nonce.XXXXXX)
  echo "$nonce" > "$TMP_FILE"
  export TMP_FILE
}

# shellcheck source=lib/common.sh
. "${LIB_DIR:-$(cd "${0%/*}/lib"&&pwd)}/common.sh"
writeConfigFor "testchain"

export CASE="$LIBEXEC_DIR/cases/$1"

[[ $# -gt 0 && ! -f "$CASE" ]] && exit 1

# Send ETH to Omnia Relayer
OMNIA_RELAYER=$(jq -r ".omniaFromAddr" "$CONFIG_FILE")
export OMNIA_RELAYER
sethSend "$OMNIA_RELAYER" --value "$(seth --to-wei 10000 eth)"

"$LIBEXEC_DIR"/base-deploy

if [[ -f "$CASE" ]]; then
    log "TESTCHAIN DEPLOYMENT + ${1} COMPLETED SUCCESSFULLY"
else
    log "TESTCHAIN DEPLOYMENT COMPLETED SUCCESSFULLY"
fi
