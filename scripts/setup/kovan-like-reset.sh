#!/usr/bin/env bash

# shellcheck source=lib/common.sh
. "./lib/common.sh"

cp "$CONFIG_DIR/deploy-kovan-live.json" "$CONFIG_DIR/deploy-kovan.json"
rm "$CONFIG_DIR/deploy-kovan-live.json"

echo "KOVAN LIKE RESET COMPLETED SUCCESSFULLY"
