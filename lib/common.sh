# Set fail flags
set -eo pipefail
shopt -s lastpipe

SOURCE_PATH=$( cd "$( dirname "$0" )" >/dev/null && pwd )

export ETH_GAS=${ETH_GAS:-"7000000"}
unset SOLC_FLAGS

# Get config variables
export CONFIG_STEP=${CONFIG_STEP?}
CONFIG_FILE="$SOURCE_PATH/$CONFIG_STEP.json"
DAPP_LIB=${DAPP_LIB:-./contracts}

test -f "$CONFIG_FILE"
