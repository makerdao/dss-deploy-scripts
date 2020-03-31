# MRS deployment scripts

A set of scripts that deploy [mrs](http://github.com/sweatdao/mrs) to an
Ethereum chain of your choosing.

## Description

This repo is composed of two steps:

* Bash [scripts](/scripts) to modify the state of the base system

At the end of the first step, the addresses of deployed contracts are written to
an `out/addresses.json` file. The scripts read those addresses and use `seth`
and `dapp` to modify the deployment, using the values in `out/config.json`.

## Installing

The only way to install everything necessary to deploy is Nix. Run

```
$ nix-shell --pure
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
A config file can be passed via param with flag `-f` allowing to execute the script in any network (e.g. `mrs-deploy testchain -f <CONFIG_FILE_PATH>`).
As other option, custom config values can be loaded as an environment variable called `DDS_CONFIG_VALUES`.
File passed by parameter overwrites the environment variable.

Below is the expected structure of such a config file:

```
{
  "description": "",
  "coin_type": "Type of deployment (BOND/STABLE)",
  "omniaFromAddr": "<Address being used by Omnia Service (only for testchain)>",
  "omniaAmount": "<Amount in ETH to be sent to Omnia Address (only for testchain)>",
  "pauseDelay": "<Delay of Pause contract in seconds>",
  "vat_line": "<General debt ceiling in COIN unit>",
  "vow_wait": "<Flop delay in seconds>",
  "vow_sump": "<Flop fixed bid size in COIN unit>",
  "vow_dump": "<Flop initial lot size in GOV unit>",
  "vow_bump": "<Flap fixed lot size in COIN unit>",
  "vow_hump": "<Flap Surplus buffer in COIN unit>",
  "jug_base": "<Base component of stability fee in percentage per year (e.g. 2.5)>",
  "pot_sr": "<Savings Rate in percentage per year (e.g. 2.5)>",
  "end_wait": "<Global Settlement cooldown period in seconds>",
  "esm_pit": "<Pit address to send GOV to be burnt when ESM is fired>",
  "esm_min": "<Minimum amount to trigger ESM in GOV unit>",
  "flip_cut": "<Minimum starting bid represented as a percentage of the oracle price feed>",
  "flap_beg": "<Minimum bid increase in percentage (e.g. 5.5)>",
  "flap_ttl": "<Max time between bids in seconds>",
  "flap_tau": "<Max auction duration in seconds>",
  "flop_beg": "<Minimum bid increase in percentage (e.g. 5.5)>",
  "flop_pad": "<Increase of lot size after `tick` in percentage (e.g. 50)>",
  "flop_ttl": "<Max time between bids in seconds>",
  "flop_tau": "<Max auction duration in seconds>",
  "oracle_quorum": "<Quorum needed to push a new price in the medianizer>",
  "multisig_owners": "<Array of addresses that will control the multisig. DEPLOYER is added automatically>",
  "multisig_quorum": "<Minimum number of addresses that need to come together to take a multisig decision. Leave empty for no multisig deployment and instead controlling the system with DEPLOYER>",
  "vox": {
    "type": "<Type of rate setter (empty string for no setter or Vox1 for BOND rate setter)>",
    "span": "<Spread between lending and borrowing (rate of change for BOND) rates>",
    "trim": "<Minimum deviation from the target price that needs to happen in order for the setter to trigger>",
    "go": "<Deviation multiplier for faster response in nullifying market forces>",
    "how": "<Sensitivity parameter to adjust rates in case the deviation is kept constantly negative/positive>",
    "dawn": "<Default per-second lending rate>",
    "dusk": "<Default per second >",
    "up": "1000000000158153903837946258",
    "down": "1000000000158153903837946258"
  },
  "gov_holders": {
    "amounts": "<Array of GOV token amounts that will be minted>",
    "holders": "<Array of wallets that will receive GOV. Mapped 1:1 with the positions in amounts>"
  },
  import: {
    "gov": "<GOV token address (if there is an existing one to import)>",
    "authority": "<Authority address (if there is an existing one to import)>",
    "proxyRegistry": "<Proxy Registry address (if there is an existing one to import)>",
    "faucet": "<Faucet address (if there is an existing one to import)>"
  },
  "tokens": {
    "<ETH|COL>": {
      "import": {
        "gem": "<Gem token address (if there is an existing one to import)>",
        "pip": "<Price feed address (if there is an existing one to import)>"
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
          "mat": "<Minimum permitted price ratio value in percentage (e.g. 150)>",
          "tam": "<Liquidation ratio value in percentage (e.g. 150)>",
          "line": "<Debt ceiling value in COIN unit>",
          "dust": "<Min amount of debt a CDP can hold in COIN unit>"
          "duty": "<Collateral component of stability fee in percentage per year (e.g. 2.5)>",
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

## Default config files

Currently, there are default config files for 3 networks:

* a local testchain (e.g. `dapp testnet`)
* Kovan
* Mainnet

### Deploy on local testchain with default config file

`mrs-deploy testchain`

It is possible to pass a value to define a testing scenario via `-c` flag (e.g. `mrs-deploy testchain -c crash-bite`)

The only case currently available is:

- `crash-bite`

### Deploy on Kovan with default config file

`mrs-deploy kovan`

### Deploy on Mainnet with default config file

`mrs-deploy main`

### Deploy on any network passing a custom config file

`mrs-deploy <NETWORK> -f <CONFIG_FILE_PATH>`

### Output

Successful deployments save their output to the following files:

- `out/addresses.json`: addresses of all deployed contracts
- `out/config.json`: copy of the configuration file used for the deployment
- `out/abi/`: JSON representation of the ABIs of all deployed contracts
- `out/bin/`: .bin and .bin-runtime files of all deployed contracts
- `out/meta/`: meta.json files of all deployed contracts
- `out/mrs-<NETWORK>.log`: output log of deployment

### Helper scripts

The `auth-checker` script loads the addresses from `out/addresses.json` and the config file from `out/config.json` and verifies that the deployed authorizations match what is expected.

## Nix

To enable full reproducibility of our deployments, we use Nix.

This command will drop you in a shell with all dependencies and environment
variables definend:

```
nix-shell --pure
```

You can even run deploy scripts without having to clone this repo:

```
nix run -f https://github.com/sweatdao/mrs-deploy-scripts/tarball/master -c mrs-deploy testchain
```

Dependencies are managed through a central repository referenced in
[`nix/pkgs.nix`](nix/pkgs.nix) and the main Nix expression to build this
repo is in [`default.nix`](default.nix).

## Smart Contract Dependencies

To update smart contract dependencies use `dapp2nix`:

```sh
nix-shell --pure
dapp2nix help
dapp2nix list
dapp2nix up vote-proxy <COMMIT_HASH>
```

To clone smart contract dependencies into working directory run:

```sh
dapp2nix clone-recursive contracts
```

## Additional Documentation

- `mrs-deploy` [source code](https://github.com/sweatdao/mrs-deploy)
- `mrs` is documented in the [wiki](https://github.com/sweatdao/mrs/wiki) and in [DEVELOPING.md](https://github.com/sweatdao/mrs/blob/master/DEVELOPING.md)

## TODO

- More cases to test scenarios for testchain script

## Latest Kovan deployment
```
# mrs kovan deployment
# TODO
```

## LICENSE
Copyright (C) 2018-2020 Maker Ecosystem Growth Holdings, INC

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
