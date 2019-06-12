# DSS deployment scripts

A set of scripts that use [DSS deploy](https://github.com/makerdao/dss-deploy) to deploy the DSS system in a testchain, testnets and mainnet.

### TODO

- More cases to test scenarios for testchain script
- Mainnet and other testnets scripts

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
For each network there is a default config file in place `deploy-<NETWORK>.json`.

```
{
  "description": "",
  "defaults": {},
  "roles": ["CREATOR"],
  "omniaFromAddr": "<Address being used by Omnia Service>",
  "pauseDelay": "<Delay of Pause contract in seconds>",
  "wait": "<Flop delay in seconds>",
  "bump": "<Flap fixed lot size in DAI unit>",
  "sump": "<Flop fixed lot size in DAI unit>",
  "hump": "<Surplus buffer in DAI unit>",
  "line": "<General debt ceiling in DAI unit>",
  "flap_beg": "<Minimum bid increase in percentage (e.g. 5.5)>",
  "flap_ttl": "<Max time between bids in seconds>",
  "flap_tau": "<Max auction duration in seconds>",
  "flop_beg": "<Minimum bid increase in percentage (e.g. 5.5)>",
  "flop_ttl": "<Max time between bids in seconds>",
  "flop_tau": "<Max auction duration in seconds>",
  "setLinesMode": "<direct|vote>",
  "tokens": {
    "<ETH|COL>": {
      "pip": {
        "osmDelay": "<Time in seconds for the OSM delay>",
        "type": "<median|value>",
        "price": "<Initial oracle price (only if type == "value")>",
        "signers": [
            <Set of signer addreeses (only if type == "median")>
        ]
      },
      "ilks": {
        "A": {
          "mat": "<Liquidation ratio value in percentage (e.g. 150)>",
          "line": "<Debt ceiling value in DAI unit>",
          "duty": "<Liquidation ratio value in percentage per year (e.g. 2.5)>",
          "chop": "<Liquidation penalty value in percentage (e.g. 12.5)>",
          "lump": "<Liquidation Quantity in Collateral Unit>",
          "beg": "<Minimum bid increase in percentage (e.g. 5.5)>",
          "ttl": "<Max time between bids in seconds>",
          "tau": "<Max auction duration in seconds>"
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
- `export ETH_RPC_URL=THE_RPC_NODE_URL`

You can use `. lib/setup-env.sh` to help you set up these variables.

If you are using `nix-shell`, `setup-env.sh` will be run automatically when you
drop into the shell.

### Testchain Deployment:

`./deploy-testchain.sh`

It is possible to pass a unique parameter to define a testing scenario (e.g. `./deploy-testchain crash-bite`)

The following cases are available:

- `crash-bite`

### Kovan Deployment:

`./deploy-kovan.sh`

### Output:

- `out/addresses.json` Group of contract addresses deployed
- `out/abi/` ABI Json files from all the contracts deployed
- `out/config.json` Copy of config json file used for deployment

### Auth checker:

`./scripts/auth-checker` (load contracts addresses from `out/addresses.json`)

### Setter Scripts:

- `./scripts/set-beg` (load contracts addresses from `out/addresses.json` and value to set from `out/config.json`)
- `./scripts/set-bump` (load contracts addresses from `out/addresses.json` and value to set from `out/config.json`)
- `./scripts/set-hump` (load contracts addresses from `out/addresses.json` and value to set from `out/config.json`)
- `./scripts/set-line` (load contracts addresses from `out/addresses.json` and value to set from `out/config.json`)
- `./scripts/set-sump` (load contracts addresses from `out/addresses.json` and value to set from `out/config.json`)
- `./scripts/set-tau <flap|flop>` (load contracts addresses from `out/addresses.json` and value to set from `out/config.json`)
- `./scripts/set-ttl <flap|flop>` (load contracts addresses from `out/addresses.json` and value to set from `out/config.json`)

- `./scripts/set-ilks-beg` (load contracts addresses from `out/addresses.json` and `ilk`s values to set from `out/config.json`)
- `./scripts/set-ilks-chop` (load contracts addresses from `out/addresses.json` and `ilk`s values to set from `out/config.json`)
- `./scripts/set-ilks-duty` (load contracts addresses from `out/addresses.json` and `ilk`s values to set from `out/config.json`)
- `./scripts/set-ilks-line` (load contracts addresses from `out/addresses.json` and `ilk`s values to set from `out/config.json`)
- `./scripts/set-ilks-lump` (load contracts addresses from `out/addresses.json` and `ilk`s values to set from `out/config.json`)
- `./scripts/set-ilks-mat` (load contracts addresses from `out/addresses.json` and `ilk`s values to set from `out/config.json`)
- `./scripts/set-ilks-price` (load contracts addresses from `out/addresses.json` and `ilk`s values to set from `out/config.json`)
- `./scripts/set-ilks-spell-line` (load contracts addresses from `out/addresses.json` and `ilk`s values to set from `out/config.json`)
- `./scripts/set-ilks-spotter-poke` (load contracts addresses from `out/addresses.json` and `ilk`s values to set from `out/config.json`)
- `./scripts/set-ilks-tau` (load contracts addresses from `out/addresses.json` and `ilk`s values to set from `out/config.json`)
- `./scripts/set-ilks-ttl` (load contracts addresses from `out/addresses.json` and `ilk`s values to set from `out/config.json`)

### Load addresses:

- `./scripts/load-addresses` (from `out/addresses.json` to ENV variables)

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
