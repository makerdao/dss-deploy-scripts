{ pkgs ? import (fetchGit {
    url = https://github.com/dapphub/dapptools.git;
    ref = dapptoolsRev;
  }) {}
, dapptoolsRev ? "6943c76bfb8e0b1fce54c3d9bba6f0f7e50d2f5c"
, eth_from
, eth_keystore ? ~/.dapp/testnet/8545/keystore
, eth_password ? "/dev/null"
}:

pkgs.mkShell {
  buildInputs = with pkgs; [ bc dapp jq ethsign seth ];

  ETH_FROM="${eth_from}";
  ETH_KEYSTORE="${eth_keystore}";
  ETH_PASSWORD="${eth_password}";
}
