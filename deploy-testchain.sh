#!/usr/bin/env bash

# shellcheck source=lib/common.sh
. "${LIB_DIR:-$(cd "${0%/*}/lib"&&pwd)}/common.sh"
writeConfigFor "testchain"

# Send ETH to Omnia Relayer
OMNIA_RELAYER=$(jq -r ".omniaFromAddr" "$CONFIG_FILE")
seth send "$OMNIA_RELAYER" --value "$(seth --to-wei 10000 eth)"

# Deploy Values or Medians + OSMs (if delay > 0) (no solc optimization)
dappBuild osm
dappBuild testchain-medians

tokens=$(jq -r ".tokens | keys_unsorted[]" "$CONFIG_FILE")
for token in $tokens; do
    type=$(jq -r ".tokens.${token} | .pip | .type" "$CONFIG_FILE")
    # Deploy Medianizer as Feed
    if [[ "$type" == "median" ]]; then
        eval "export VAL_$token=$(dappCreate testchain-medians "Median${token}USD")"
        signers=$(jq -r ".tokens.${token} | .pip | .signers | .[]" "$CONFIG_FILE")
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
    osm_delay=$(jq -r ".tokens.${token} | .pip | .osmDelay" "$CONFIG_FILE")
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
done

"$LIBEXEC_DIR"/base-deploy

loadAddresses

# Whitelist Spotter
for token in $tokens; do
    osm_delay=$(jq -r ".tokens.${token} | .pip | .osmDelay" "$CONFIG_FILE")
    type=$(jq -r ".tokens.${token} | .pip | .type" "$CONFIG_FILE")
    if [[ "$osm_delay" -gt 0 ]]; then
        # Whitelist Spotter in OSM
        seth send "$(eval echo "\$PIP_${token}")" 'kiss(address)' "$(eval echo "\$MCD_SPOT")"
    elif [[ "$type" == "median" ]]; then
        # Whitelist Spotter in Medianizer
        seth send "$(eval echo "\$VAL_${token}")" 'kiss(address)' "$(eval echo "\$MCD_SPOT")"
    fi
done

"$LIBEXEC_DIR"/set-ilks-mat

setLinesMode=$(jq -r ".setLinesMode" "$CONFIG_FILE")
if [[ $setLinesMode = "direct" ]]; then
    "$LIBEXEC_DIR"/set-ilks-line
elif [[ $setLinesMode = "vote" ]]; then
    "$LIBEXEC_DIR"/set-ilks-spell-line
fi

"$LIBEXEC_DIR"/set-ilks-duty

"$LIBEXEC_DIR"/set-ilks-price

"$LIBEXEC_DIR"/set-ilks-spotter-poke

"$LIBEXEC_DIR"/set-ilks-chop

"$LIBEXEC_DIR"/set-ilks-lump

"$LIBEXEC_DIR"/set-ilks-beg

"$LIBEXEC_DIR"/set-ilks-ttl

"$LIBEXEC_DIR"/set-ilks-tau

if [[ "$1" != "" ]]; then
    "$LIBEXEC_DIR/cases/$1"
fi

"$LIBEXEC_DIR"/set-pause-auth-delay

if [[ "$1" != "" ]]; then
    echo "TESTCHAIN DEPLOYMENT + ${1} COMPLETED SUCCESSFULLY"
else
    echo "TESTCHAIN DEPLOYMENT COMPLETED SUCCESSFULLY"
fi
