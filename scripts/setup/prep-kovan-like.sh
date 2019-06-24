#!/usr/bin/env bash

# shellcheck source=lib/common.sh
. "${LIB_DIR:-$(cd "${0%/*}/lib"&&pwd)}/common.sh"
setConfigFile "kovan-dryrun"

# Setup steps

# Send ETH to Omnia Relayer
OMNIA_RELAYER=$(jq -r ".omniaFromAddr" "$CONFIG_FILE")
seth send "$OMNIA_RELAYER" --value "$(seth --to-wei 10000 eth)"

# Export it so we can use it in pips-deploy
export OMNIA_RELAYER

"$LIBEXEC_DIR"/pips-deploy

# Run Deployment
"$BIN_DIR"/deploy-kovan.sh

echo "KOVAN DRYRUN PREP COMPLETED SUCCESSFULLY"
