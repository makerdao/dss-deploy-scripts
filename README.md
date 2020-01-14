# DSS deployment scripts

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
A config file can be passed via param with flag `-f` allowing to execute the script in any network (e.g. `dss-deploy testchain -f <CONFIG_FILE_PATH>`).
As other option, custom config values can be loaded as an environment variable called `DDS_CONFIG_VALUES`.
File passed by parameter overwrites the environment variable.

Below is the expected structure of such a config file:

```
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
  "jug_base": "<Base component of stability fee in percentage per year (e.g. 2.5)>",
  "pot_dsr": "<Dai Savings Rate in percentage per year (e.g. 2.5)>",
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
  import: {
    "gov": "<GOV token address (if there is an existing one to import)>",
    "authority": "<Authority address (if there is an existing one to import)>",
    "proxyRegistry": "<Proxy Registry address (if there is an existing one to import)>",
    "faucet": "<Faucet address (if there is an existing one to import)>"
  },
  "migration": {
    "tub": "<SCD tub address>",
    "ethAdapterVarName": "<Name of ETH adapter being used by the migration contract (e.g. MCD_JOIN_ETH_A)>",
    "line": "<SAI Collateral Debt ceiling in DAI unit>"
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
          "mat": "<Liquidation ratio value in percentage (e.g. 150)>",
          "line": "<Debt ceiling value in DAI unit>",
          "dust": "<Min amount of debt a CDP can hold in DAI unit>"
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

`dss-deploy testchain`

It is possible to pass a value to define a testing scenario via `-c` flag (e.g. `dss-deploy testchain -c crash-bite`)

The only case currently available is:

- `crash-bite`

### Deploy on Kovan with default config file

`dss-deploy kovan`

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

```
nix-shell --pure
```

You can even run deploy scripts without having to clone this repo:

```
nix run -f https://github.com/makerdao/dss-deploy-scripts/tarball/master -c dss-deploy testchain
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

- `dss-deploy` [source code](https://github.com/makerdao/dss-deploy)
- `dss` is documented in the [wiki](https://github.com/makerdao/dss/wiki) and in [DEVELOPING.md](https://github.com/makerdao/dss/blob/master/DEVELOPING.md)

## TODO

- More cases to test scenarios for testchain script

## Latest Mainnet deployment
```
# dss mainnet deployment
# Wed Nov 13 2019
export DEPLOYER=0xdDb108893104dE4E1C6d0E47c42237dB4E617ACc
export MULTICALL=0x5e227AD1969Ea493B43F840cfF78d08a6fc17796
export FAUCET=0x0000000000000000000000000000000000000000
export MCD_DEPLOY=0xbaa65281c2FA2baAcb2cb550BA051525A480D3F4
export MCD_GOV=0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2
export GOV_GUARD=0x6eEB68B2C7A918f36B78E2DB80dcF279236DDFb8
export MCD_ADM=0x9eF05f7F6deB616fd37aC3c959a2dDD25A54E4F5
export MCD_VAT=0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B
export MCD_JUG=0x19c0976f590D67707E62397C87829d896Dc0f1F1
export MCD_CAT=0x78F2c2AF65126834c51822F56Be0d7469D7A523E
export MCD_VOW=0xA950524441892A31ebddF91d3cEEFa04Bf454466
export MCD_JOIN_DAI=0x9759A6Ac90977b93B58547b4A71c78317f391A28
export MCD_FLAP=0xdfE0fb1bE2a52CDBf8FB962D5701d7fd0902db9f
export MCD_FLOP=0x4D95A049d5B0b7d32058cd3F2163015747522e99
export MCD_PAUSE=0xbE286431454714F511008713973d3B053A2d38f3
export MCD_PAUSE_PROXY=0xBE8E3e3618f7474F8cB1d074A26afFef007E98FB
export MCD_GOV_ACTIONS=0x4F5f0933158569c026d617337614d00Ee6589B6E
export MCD_DAI=0x6B175474E89094C44Da98b954EedeAC495271d0F
export MCD_SPOT=0x65C79fcB50Ca1594B025960e539eD7A9a6D434A3
export MCD_POT=0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7
export MCD_END=0xaB14d3CE3F733CACB76eC2AbE7d2fcb00c99F3d5
export MCD_ESM=0x0581A0AbE32AAe9B5f0f68deFab77C6759100085
export PROXY_ACTIONS=0x82ecD135Dce65Fbc6DbdD0e4237E0AF93FFD5038
export PROXY_ACTIONS_END=0x069B2fb501b6F16D1F5fE245B16F6993808f1008
export PROXY_ACTIONS_DSR=0x07ee93aEEa0a36FfF2A9B95dd22Bd6049EE54f26
export CDP_MANAGER=0x5ef30b9986345249bc32d8928B7ee64DE9435E39
export GET_CDPS=0x36a724Bd100c39f0Ea4D3A20F7097eE01A8Ff573
export PROXY_FACTORY=0xA26e15C895EFc0616177B7c1e7270A4C7D51C997
export PROXY_REGISTRY=0x4678f0a6958e4D2Bc4F1BAF7Bc52E8F3564f3fE4
export ETH=0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
export VAL_ETH=0x81FE72B5A8d1A857d176C3E7d5Bd2679A9B85763
export PIP_ETH=0x81FE72B5A8d1A857d176C3E7d5Bd2679A9B85763
export MCD_JOIN_ETH_A=0x2F0b23f53734252Bda2277357e97e1517d6B042A
export MCD_FLIP_ETH_A=0xd8a04F5412223F513DC55F839574430f5EC15531
export BAT=0x0D8775F648430679A709E98d2b0Cb6250d2887EF
export VAL_BAT=0xB4eb54AF9Cc7882DF0121d26c5b97E802915ABe6
export PIP_BAT=0xB4eb54AF9Cc7882DF0121d26c5b97E802915ABe6
export MCD_JOIN_BAT_A=0x3D0B1912B66114d4096F48A8CEe3A56C231772cA
export MCD_FLIP_BAT_A=0xaA745404d55f88C108A28c86abE7b5A1E7817c07
export SAI=0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359
export PIP_SAI=0x54003DBf6ae6CBa6DDaE571CcdC34d834b44Ab1e
export MCD_JOIN_SAI=0xad37fd42185Ba63009177058208dd1be4b136e6b
export MCD_FLIP_SAI=0x5432b2f3c0DFf95AA191C45E5cbd539E2820aE72
export PROXY_PAUSE_ACTIONS=0x6bda13D43B7EDd6CAfE1f70fB98b5d40f61A1370
export PROXY_DEPLOYER=0x1b93556AB8dcCEF01Cd7823C617a6d340f53Fb58
export SAI_TUB=0x448a5065aeBB8E423F0896E6c5D525C040f59af3
export MIGRATION=0xc73e0383F3Aff3215E6f04B0331D58CeCf0Ab849
export MIGRATION_PROXY_ACTIONS=0x2E1F6062d9fB227069741E40f89186DF222FB426
```
