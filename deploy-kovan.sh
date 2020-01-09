#!/usr/bin/env bash

# shellcheck source=lib/check-params.sh
. "$LIB_DIR/check-params.sh"

# shellcheck source=lib/common.sh
. "$LIB_DIR/common.sh"

writeConfigFor "kovan"

test "$(seth chain)" == "kovan" || exit 1

export DEPLOY_RESTRICTED_FAUCET="no"
"$LIBEXEC_DIR"/base-deploy |& tee "$OUT_DIR/dss_kovan.log"

log "KOVAN DEPLOYMENT COMPLETED SUCCESSFULLY"
