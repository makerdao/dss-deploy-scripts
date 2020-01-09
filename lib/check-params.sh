#!/usr/bin/env bash

set -e

if [[ "$IN_NIX_SHELL" != "yes" ]]; then
    echo "This command must be run via nix-shell"
    exit 1
fi
if [[ -z "$BIN_DIR" ]]; then
    echo "This command must be called without \"./\""
    exit 1
fi

setCase() {
    export CASE="$LIBEXEC_DIR/cases/$1"
    [[ $# -gt 0 && ! -f "$CASE" ]] && exit 1
}

while getopts "c:f:" opt; do
    case "$opt" in 
        c) setCase "$OPTARG";;
        f) export CONFIG="$OPTARG" ;;
        *) ;;
    esac
done
