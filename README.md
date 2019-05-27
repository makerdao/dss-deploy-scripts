# Testchain DSS deployment scripts

A set of scripts that use [DSS deploy](https://github.com/makerdao/dss-deploy) to deploy the DSS system in a testchain.

### TODO

- Steps 3, 5, 6, 8, 9, 10, 11, 12, 13, 14 and 15

## Additional Documentation

- `dss-deploy` [source code](https://github.com/makerdao/dss-deploy)
- `dss` is documented in the [wiki](https://github.com/makerdao/dss/wiki) and in [DEVELOPING.md](https://github.com/makerdao/dss/blob/master/DEVELOPING.md)

## Deployment

### Prerequisites:

If you use nix, run `nix-shell` to drop into a shell with all dependencies
installed.

Otherwise:

- seth/dapp/jq/mcd (https://dapp.tools/)
- bc

Either way, you'll need to have an Ethereum node running, e.g. `dapp testnet` or
`parity --chain=dev --tracing=on --fat-db=on --pruning=archive`.

### Config File:
For each step there is a default config file in place `step-<STEP>.json`.

```
{
  "description": "Step X - What step does",
  "defaults": {},
  "roles": ["CREATOR"],
  "omniaFromAddr": "<Address being used by Omnia Service>",
  "tokens": {
    "<ETH/REP>": {
      "pip": {
        "osmDelay": "<Time in seconds for the OSM delay>",
        "type": "<median/value>",
        "signers": [
            <Set of signer addreeses (only if type == "median")>
        ],
        "price": "<Initial oracle price (only if type == "value")>"
      },
      "ilks": {
        "A": {
          "mat": "<liquidation ratio value>"
        }
      }
    }
  }
}
```

### Pre-deploy:

- `export ETH_FROM=DEPLOYMENT_ACCOUNT`
- `export ETH_PASSWORD=ACCOUNT_PASSWORD_FILE_PATH`
- `export ETH_KEYSTORE=KEYSTORE_PATH`
- `export ETH_RPC_URL=TESTNET_RPC_NODE_URL`

You can use `. lib/setup-env.sh` to help you set up these variables.

If you are using `nix-shell`, `setup-env.sh` will be run automatically when you
drop into the shell.

### Deploy:

- Step 1: `./step-1-deploy`
- Step 2: `./step-2-deploy`
- Step 3: `./step-3-deploy`
- Step 4: `./step-4-deploy`
- Step 7: `./step-7-deploy`

### Output:

- `out/addresses.json` Group of contract addresses deployed
- `out/abi/` ABI Json files from all the contracts deployed
- `out/config.json` Copy of config json file used for deployment

### Update Price:

`./scripts/set-price <token> <price>` (load variables from `out/addresses.json`)

### Load addresses:

`./scripts/load-addresses` (from `out/addresses.json` to ENV variables)

## Nix

To be able to easily share scripts with other repos and make sure that the
exact dependencies needed to run the scripts are met we can use Nix.

You can now run deploy scripts without having to clone this repo:

```
nix run -f https://github.com/makerdao/testchain-dss-deployment-scripts/tarball/master -c step-1-deploy
```

After changing submodules the lock file [`nix/dapp.nix`](nix/dapp.nix)
needs to be updated using `dapp2nix`. This is to avoid downloading all
submodules when installing the deploy scripts without cloning `tdds`.

```sh
nix-shell
dapp2nix nix/dapp.nix
```

Dependencies are managed through a central repository referenced in
[`nix/pkgs.nix`](nix/pkgs.nix) and the main Nix expression to build this
repo is in [`default.nix`](default.nix).
