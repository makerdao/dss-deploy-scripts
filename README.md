# DSS deployment scripts

![Build Status](https://github.com/makerdao/dss-deploy-scripts/actions/workflows/.github/workflows/tests.yaml/badge.svg?branch=master)

A set of scripts that deploy [dss](http://github.com/makerdao/dss) to an
Ethereum chain of your choosing.

## Description

This repo is composed of two steps:

* Bash [scripts](/scripts) to modify the state of the base system

At the end of the first step, the addresses of deployed contracts are written to
an `out/addresses.json` file. The scripts read those addresses and use `seth`
and `dapp` to modify the deployment, using the values in `out/config.json`.

## Installing

The only way to install everything necessary to deploy is Nix. Run

```shell
nix-shell --pure
```

to drop into a Bash shell with all dependency installed.

### Ethereum node

You'll also need an Ethereum RPC node to connect to. Depending on your usecase, this
could be a local node (e.g. `dapp testnet`) or a remote one.

## Configuration

There are 2 main pieces of configuration necessary for a deployment:

* Ethereum account configuration
* Chain configuration

#### Account configuration

`seth` relies on the presence of environment variables to know which Ethereum account to
use, which RPC server to talk to, etc.

If you're using `nix-shell`, these variables are set automatically for you in
[shell.nix](./shell.nix).

But you can also configure the below variables manually:

- `ETH_FROM`: address of deployment account
- `ETH_PASSWORD`: path of account password file
- `ETH_KEYSTORE`: keystore path
- `ETH_RPC_URL`: URL of the RPC node

### Chain configuration

Some networks have a default config file at `config/<NETWORK>.json`, which will be used if non custom config values are set.
A config file can be passed via param with flag `-f` allowing to execute the script in any network (e.g. `dss-deploy testchain -f <CONFIG_FILE_PATH>`).
As other option, custom config values can be loaded as an environment variable called `DDS_CONFIG_VALUES`.
File passed by parameter overwrites the environment variable.

Below is the expected structure of such a config file:

```json
{
  "description": "",
  "omniaFromAddr": "<Address being used by Omnia Service (only for testchain)>",
  "omniaAmount": "<Amount in ETH to be sent to Omnia Address (only for testchain)>",
  "pauseDelay": "<Delay of Pause contract in seconds>",
  "vat_line": "<General debt ceiling in DAI unit>",
  "vow_wait": "<Flop delay in seconds>",
  "vow_sump": "<Flop fixed bid size in DAI unit>",
  "vow_dump": "<Flop initial lot size in MKR unit>",
  "vow_bump": "<Flap fixed lot size in DAI unit>",
  "vow_hump": "<Flap Surplus buffer in DAI unit>",
  "cat_box": "<Max total DAI needed to cover all debt plus penalty fees on active Flip auctions in DAI unit>",
  "dog_hole": "<Max total DAI needed to cover all debt plus penalty fees on active Clip auctions in DAI unit>",
  "jug_base": "<Base component of stability fee in percentage per year (e.g. 2.5)>",
  "pot_dsr": "<Dai Savings Rate in percentage per year (e.g. 2.5)>",
  "cure_wait": "<Cure cooldown period in seconds>",
  "end_wait": "<Global Settlement cooldown period in seconds>",
  "esm_pit": "<Pit address to send MKR to be burnt when ESM is fired>",
  "esm_min": "<Minimum amount to trigger ESM in MKR unit>",
  "flap_beg": "<Minimum bid increase in percentage (e.g. 5.5)>",
  "flap_ttl": "<Max time between bids in seconds>",
  "flap_tau": "<Max auction duration in seconds>",
  "flop_beg": "<Minimum bid increase in percentage (e.g. 5.5)>",
  "flop_pad": "<Increase of lot size after `tick` in percentage (e.g. 50)>",
  "flop_ttl": "<Max time between bids in seconds>",
  "flop_tau": "<Max auction duration in seconds>",
  "flap_lid": "<Max amount of DAI that can be put up for sale at the same time in DAI unit (e.g. 1000000)>",
  "flash_max": "<Max DAI can be borrowed from flash loan module in DAI unit (e.g. 1000000)>",
  "import": {
    "gov": "<GOV token address (if there is an existing one to import)> note: make sure to mint enough tokens for launch",
    "authority": "<Authority address (if there is an existing one to import)> note: make sure to launch MCD_ADMIN",
    "proxyRegistry": "<Proxy Registry address (if there is an existing one to import)>",
    "faucet": "<Faucet address (if there is an existing one to import)>"
  },
  "tokens": {
    "<ETH|COL>": {
      "import": {
        "gem": "<Gem token address (if there is an existing one to import)>",
        "pip": "<Price feed address (if there is an existing one to import)>"
      },
      "gemDeploy": { // Only used if there is not a gem imported
        "src": "<REPO/CONTRACT (e.g. dss-gem-joins/GemJoin2)>",
        "params": [<Any params to be passed to the constructor of the token in its native form (e.g. amounts in wei or strings in hex encoding)>],
        "faucetSupply": "<Amount of token to be transferred to the faucet>",
        "faucetAmount": "<Amount of token to be obtained in each faucet gulp (only if a new faucet is deployed)>"
      },
      "joinDeploy": { // Mandatory always
        "src": "<GemJoin/GemJoin2/GemJoinX>",
        "extraParams": [<Any extra params to be passed to the constructor of the join in its native form (e.g. amounts in wei or strings in hex encoding)>]
      },
      "pipDeploy": { // Only used if there is not a pip imported
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
          "line": "<Debt ceiling value in DAI unit (won't be used if autoLine is > 0)>",
          "autoLine": "<Max debt ceiling value in DAI unit (for DssAutoLine IAM)>",
          "autoLineGap": "<Value to set the ceiling over the current ilk debt in DAI unit (for DssAutoLine IAM)>",
          "autoLineTtl": "<Time between debt ceiling increments (for DssAutoLine IAM)>",
          "dust": "<Min amount of debt a CDP can hold in DAI unit>"
          "duty": "<Collateral component of stability fee in percentage per year (e.g. 2.5)>",
          "flipDeploy": {
            "chop": "<Liquidation penalty value in percentage (e.g. 12.5)>",
            "dunk": "<Liquidation Quantity in DAI Unit>",
            "beg": "<Minimum bid increase in percentage (e.g. 5.5)>",
            "ttl": "<Max time between bids in seconds>",
            "tau": "<Max auction duration in seconds>"
          },
          "clipDeploy": { // Will be used only if there isn't a flipDeploy
            "chop": "<Liquidation penalty value in percentage (e.g. 12.5)>",
            "hole": "<Max DAI needed to cover debt+fees of active auctions per ilk (e.g. 100,000 DAI)>",
            "chip": "<Percentage of due to suck from vow to incentivize keepers (e.g. 2%)>",
            "tip": "<Flat fee to suck from vow to incentivize keepers (e.g. 100 DAI)>",
            "buf": "<Multiplicative factor to increase starting price (e.g. 125%)>",
            "tail": "<Time elapsed before auction reset in seconds>",
            "cusp": "<Percentage taken for the new price before auction reset (e.g. 30%)>",
            "calc": {
              "type": "LinearDecrease/StairstepExponentialDecrease/ExponentialDecrease",
              "tau":  "<Time after auction start when the price reaches zero in seconds (LinearDecrease)>",
              "step": "<Length of time between price drops in seconds (StairstepExponentialDecrease)>",
              "cut":  "<Percentage to be taken as new price per step (e.g. 99%, which is 1% drop) (StairstepExponentialDecrease/ExponentialDecrease)>"
            },
            "cm_tolerance": "<Percentage of previous price which a drop would enable anyone to be able to circuit break the liquidator via ClipperMom (e.g. 50%)>"
          }
        }
      }
    }
  }
}
```
NOTE: Make sure to mint enough (threshold is 80,000 MKR) tokens for launch if you are providing it in `config.gov`:
```
    sethSend "$MCD_GOV" 'mint(address,uint256)' "$ETH_FROM" "$(seth --to-uint256 "$(seth --to-wei 1000000 ETH)")"
```
NOTE: Make sure to `launch` MCD_ADMIN if you are providing it in `config.authority`.
```
    # lock enough MKR (80,000 MKR threshold)
    sethSend "$MCD_GOV" "approve(address,uint256)" "$MCD_ADM" "$(seth --to-uint256 "$(seth --to-wei 80000 ETH)")"
    sethSend "$MCD_ADM" "lock(uint256)" "$(seth --to-uint256 "$(seth --to-wei 80000 ETH)")"
    sethSend "$MCD_ADM" "vote(address[])" "[0x0000000000000000000000000000000000000000]"
    sethSend "$MCD_ADM" "launch()"
```

## Default config files

Currently, there are default config files for 3 networks:

- a local testchain (e.g. `dapp testnet`)
- Goerli
- Mainnet

### Deploy on local testchain with default config file

`dss-deploy testchain`

It is possible to pass a value to define a testing scenario via `-c` flag (e.g. `dss-deploy testchain -c crash-bite`)

The only case currently available is:

- `crash-bite`

### Deploy on Goerli with default config file

`dss-deploy goerli`

### Deploy on Mainnet with default config file

`dss-deploy main`

### Deploy on any network passing a custom config file

`dss-deploy <NETWORK> -f <CONFIG_FILE_PATH>`

### Output

Successful deployments save their output to the following files:

- `out/addresses.json`: addresses of all deployed contracts
- `out/config.json`: copy of the configuration file used for the deployment
- `out/abi/`: JSON representation of the ABIs of all deployed contracts
- `out/bin/`: .bin and .bin-runtime files of all deployed contracts
- `out/meta/`: meta.json files of all deployed contracts
- `out/dss-<NETWORK>.log`: output log of deployment

### Helper scripts

The `auth-checker` script loads the addresses from `out/addresses.json` and the config file from `out/config.json` and verifies that the deployed authorizations match what is expected.

## Nix

To enable full reproducibility of our deployments, we use Nix.

This command will drop you in a shell with all dependencies and environment
variables definend:

```shell
nix-shell --pure
```

You can even run deploy scripts without having to clone this repo:

```shell
nix run -f https://github.com/makerdao/dss-deploy-scripts/tarball/master -c dss-deploy testchain
```

Dependencies are managed through a central repository referenced in
[`nix/pkgs.nix`](nix/pkgs.nix) and the main Nix expression to build this
repo is in [`default.nix`](default.nix).

## Smart Contract Dependencies

To update smart contract dependencies use `dapp2nix`:

```shell
nix-shell --pure
dapp2nix help
dapp2nix list
dapp2nix up vote-proxy <COMMIT_HASH>
```

To clone smart contract dependencies into working directory run:

```shell
dapp2nix clone-recursive contracts
```

## Additional Documentation

- `dss-deploy` [source code](https://github.com/makerdao/dss-deploy)
- `dss` is documented in the [wiki](https://github.com/makerdao/dss/wiki) and in [DEVELOPING.md](https://github.com/makerdao/dss/blob/master/DEVELOPING.md)

## TODO

- More cases to test scenarios for testchain script
