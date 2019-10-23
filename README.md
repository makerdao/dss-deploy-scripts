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

Each supported `$NETWORK` has a default config file at `deploy-$NETWORK.json`.

Below is the expected structure of such a config file:

```
{
  "description": "",
  "defaults": {},
  "roles": ["CREATOR"],
  "omniaFromAddr": "<Address being used by Omnia Service (only for testchain)>",
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
  "esm_min": "<Minimum amount to trigger ESM in MKR unit>",
  "flap_beg": "<Minimum bid increase in percentage (e.g. 5.5)>",
  "flap_ttl": "<Max time between bids in seconds>",
  "flap_tau": "<Max auction duration in seconds>",
  "flop_beg": "<Minimum bid increase in percentage (e.g. 5.5)>",
  "flop_pad": "<Increase of lot size after `tick` in percentage (e.g. 50)>",
  "flop_ttl": "<Max time between bids in seconds>",
  "flop_tau": "<Max auction duration in seconds>",
  "setLinesMode": "<direct|vote|(any other value will do nothing about debt ceilings)>",
  "gov": "<GOV token address (if there is an existing one to import)>",
  "authority": "<Authority address (if there is an existing one to import)>",
  "proxyRegistry": "<Proxy Registry address (if there is an existing one to import)>",
  "faucet": "<Faucet address (if there is an existing one to import)>",
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
          "dust": "<Min amount of debt a CDP can hold in DAI unit (rad)>"
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

## Deployment

Currently, 2 networks are supported:

* a local testchain (e.g. `dapp testnet`)
* Kovan

### Local testchain

`./deploy-testchain.sh`

It is possible to pass a unique parameter to define a testing scenario (e.g. `./deploy-testchain.sh crash-bite`)

The following cases are currently available:

- `crash-bite`

### Kovan

`./deploy-kovan.sh`

### Output

Successful deployments save their output to the following files:

- `out/addresses.json`: addresses of all deployed contracts
- `out/abi/`: JSON representation of the ABIs of all deployed contracts
- `out/config.json`: copy of the configuration file used for the deployment

### Helper scripts

The [`auth-checker`](./scripts/auth-checker) script loads the addresses
in `out/addresses.json` and verifies that the deployed authorizations match what
is expected.

## Nix

To enable full reproducibility of our deployments, we use Nix.

This command will drop you in a shell with all dependencies and environment
variables definend:

```
nix-shell --pure
```

You can even run deploy scripts without having to clone this repo:

```
nix run -f https://github.com/makerdao/dss-deploy-scripts/tarball/master -c deploy-testchain.sh
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
