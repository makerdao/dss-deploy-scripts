{ pkgs ? import (fetchGit {
    url = https://github.com/dapphub/dapptools.git;
    rev = "6943c76bfb8e0b1fce54c3d9bba6f0f7e50d2f5c";
  }) {}
, mcd-cli ? pkgs.callPackage (import (fetchGit {
    url = https://github.com/makerdao/mcd-cli.git;
    rev = "86842b49defa53301ac0019f7d5994859bb3e1e9";
  })) {}
, eth_from
, eth_keystore ? ~/.dapp/testnet/8545/keystore
, eth_password ? "/dev/null"
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    dapp ethsign seth mcd-cli
    bc jq coreutils
  ];

  ETH_FROM="${eth_from}";
  ETH_KEYSTORE="${eth_keystore}";
  ETH_PASSWORD="${eth_password}";
}
