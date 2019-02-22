# Testchain DSS deployment scripts

A set of scripts that use [DSS deploy](https://github.com/makerdao/dss-deploy) to deploy the DSS system in a testchain.

### TODO

- Steps 3, 5, 6, 8, 9, 10, 11, 12, 13, 14 and 15

## Additional Documentation

- `dss-deploy` [source code](https://github.com/makerdao/dss-deploy)
- `dss` is documented in the [wiki](https://github.com/makerdao/dss/wiki) and in [DEVELOPING.md](https://github.com/makerdao/dss/blob/master/DEVELOPING.md)

## Deployment

### Prerequisites:

If you use nix, run `nix-shell --argstr eth_from $ETH_FROM` to drop in a shell with all dependencies
installed.

Otherwise:

- seth/dapp/jq/mcd (https://dapp.tools/)
- bc

Either way, you'll need to have an Ethereum node running, e.g. `dapp testnet`.

### Config File:
For each step there is a default config file in place `step-<STEP>.json`.

```
{
  "description": "Step X - What step does",
  "defaults": {},
  "roles": ["CREATOR"],
  "omniaFromAddr": "<Address being used by Omnia Service>",
  "ilks": {
    "<ETH/REP>": {
      "pip": {
        "osmDelay": "<Time in seconds for the OSM delay>",
        "type": "<median/value>",
        "signers": [
            <Set of signer addreeses (only if type == "median")>
        ],
        "price": "<Initial oracle price (only if type == "value")>"
      },
      "mat": "<liquidation ratio value>"
    }
  }
}
```

### Pre-deploy:
- `export ETH_FROM=DEPLOYMENT_ACCOUNT`
- `export ETH_PASSWORD=ACCOUNT_PASSWORD_FILE_PATH`
- `export ETH_KEYSTORE=KEYSTORE_PATH`
- `export ETH_RPC_URL=TESTNET_RPC_NODE_URL`

### Deploy:

- Step 1: `./step-1-deploy`
- Step 2: `./step-2-deploy`
- Step 4: `./step-4-deploy`
- Step 7: `./step-7-deploy`

### Output:

- `out/addresses.json` Group of contract addresses deployed
- `out/abi/` ABI Json files from all the contracts deployed
- `out/config.json` Copy of config json file used for deployment

### Update Price:

`./update-price <ilk> <price>` (load variables from `out/addresses.json`)

### Load addresses:

`./load-addresses` (from `out/addresses.json` to ENV variables)
