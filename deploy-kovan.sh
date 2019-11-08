#!/usr/bin/env bash

# shellcheck source=lib/common.sh
. "${LIB_DIR:-$(cd "${0%/*}/lib"&&pwd)}/common.sh"
writeConfigFor "kovan"

test "$(seth chain)" == "kovan" || exit 1

export DEPLOY_RESTRICTED_FAUCET="no"
"$LIBEXEC_DIR"/base-deploy

log "KOVAN DEPLOYMENT COMPLETED SUCCESSFULLY"
