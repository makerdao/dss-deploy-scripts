#!/usr/bin/env bash

jq_inplace() {
  local tmp; tmp=$(mktemp)
  local query; query=$1
  local file; file=$2
  jq "$query" "$file" > "$tmp" && mv "$tmp" "$file"
}

# shellcheck source=lib/common.sh
. "./lib/common.sh"
rm -rf "$OUT_DIR" && mkdir "$OUT_DIR"
export SETUP_CONFIG_FILE="${LIBEXEC_DIR:-$BIN_DIR}/setup/kovan-like-config.json"

# Setup steps

# Send ETH to Omnia Relayer
OMNIA_RELAYER=$(jq -r ".omniaFromAddr" "$SETUP_CONFIG_FILE")
seth send "$OMNIA_RELAYER" --value "$(seth --to-wei 10000 eth)"

# Deploy Values or Medians + OSMs (if delay > 0) (no solc optimization)
dappBuild osm
dappBuild testchain-medians

tokens=$(jq -r ".tokens | keys_unsorted[]" "$SETUP_CONFIG_FILE")
for token in $tokens; do
    type=$(jq -r ".tokens.${token} | .pipDeploy | .type" "$SETUP_CONFIG_FILE")
    # Deploy Medianizer as Feed
    if [[ "$type" == "median" ]]; then
        eval "export VAL_$token=$(dappCreate testchain-medians "Median${token}USD")"
        signers=$(jq -r ".tokens.${token} | .pipDeploy | .signers | .[]" "$SETUP_CONFIG_FILE")
        # Approve oracle price feed providers
        for signer in $signers; do
            seth send "$(eval echo "\$VAL_${token}")" 'lift(address)' "$signer"
        done
        # Set quorum for Medianizer
        seth send "$(eval echo "\$VAL_${token}")" 'setBar(uint256)' "$(seth --to-uint256 3)"
        # Whitelist Omnia relayer to read price from Medianizer
        seth send "$(eval echo "\$VAL_${token}")" 'kiss(address)' "$OMNIA_RELAYER"
    fi
    # Deploy DSValue as Feed
    if [[ "${type}" == "value" ]]; then
        eval "export VAL_$token=$(dappCreate osm DSValue)"
    fi
    # Deploy OSM if delay > 0
    osm_delay=$(jq -r ".tokens.${token} | .pipDeploy | .osmDelay" "$SETUP_CONFIG_FILE")
    if [[ "$osm_delay" -gt 0 ]]; then
        # Deploy OSM
        eval "export PIP_$token=$(dappCreate osm OSM "$(eval echo "\$VAL_${token}")")"
        # Set OSM delay
        seth send "$(eval echo "\$PIP_${token}")" 'step(uint16)' "$osm_delay"
        # Whitelist OSM in Medianizer (skip if source is DSValue)
        [[ "$type" == "median" ]] && seth send "$(eval echo "\$VAL_${token}")" 'kiss(address)' "$(eval echo "\$PIP_${token}")"
    else
        eval export "PIP_${token}=\$VAL_${token}"
    fi
    jq_inplace ".tokens.${token}.pip = \"$(eval echo "\$PIP_${token}")\"" "$SETUP_CONFIG_FILE"
done

log "pips deployed"

cp "$CONFIG_DIR/deploy-kovan.json" "$CONFIG_DIR/deploy-kovan-live.json"
cp "$SETUP_CONFIG_FILE" "$CONFIG_DIR/deploy-kovan.json"

log "temp kovan config created"

export SIMULATE="kovan"
"$CONFIG_DIR/deploy-kovan.sh"

# Reset Kovan Config File
cp "$CONFIG_DIR/deploy-kovan-live.json" "$CONFIG_DIR/deploy-kovan.json"
rm "$CONFIG_DIR/deploy-kovan-live.json"

log "kovan config reset"

set +x
echo "******************************************"
log "KOVAN LIKE DEPLOY COMPLETED SUCCESSFULLY"
echo "******************************************"
echo "STEPS TAKEN"
log "Sent ETH to OMNIA"
log "Deployed MEDIAN Pips for COLs"
log "Saved PIP ADDR to prep config file"
log "Copied real Kovan Config file to preserve it"
log "Copied prep Config file to for use with deploy kovan"
log "Ran deploy-kovan"
log "Reset kovan config file"
echo "******************************************"
set -x
