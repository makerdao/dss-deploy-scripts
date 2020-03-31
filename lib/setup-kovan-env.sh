#!/usr/bin/env bash
[[ "$_" != "$0" ]] || { echo >&2 "Use this script by sourcing it \`. $0\` instead"; exit 1; }

echo "Using Infura to deploy on KOVAN"

# Set dapptools environment variables
export ETH_RPC_URL="https://kovan.infura.io/v3/8955c2cd42224317957bb42869772df8" # add your Infura token when you deploy and remove before you push code
export ETH_GAS=6500000
export ETH_PASSWORD="$HOME/.dapp/testnet/kovan/StorePass" # set the path to the file containing the password
export ETH_KEYSTORE="$HOME/.dapp/testnet/kovan/keystore"
export ETH_FROM="0xF6567201430b8823bF0ED3B7A2953D557270db7e"
export JSON_RPC="$ETH_RPC_URL"

# For yin.js tests
if command -v sethret > /dev/null 2>&1; then
  find_keyfile() {
    local address
    address="$(tr '[:upper:]' '[:lower:]' <<<"${2#0x}")"
    while IFS= read -r -d '' file; do
      if [[ "$(jq -r .address "$file")" == "$address" ]]; then
        echo "$file"
        break
      fi
    done < <(find "$1" -type f -print0)
  }
  PRIVATE_KEY="$(sethret "$(find_keyfile "$ETH_KEYSTORE" "$ETH_FROM")" "$(cat "$ETH_PASSWORD")")"
  export PRIVATE_KEY
fi

echo "=== DAPPTOOLS VARIABLES ==="
env | grep ETH_
seth --version | head -n1
dapp --version | head -n1
