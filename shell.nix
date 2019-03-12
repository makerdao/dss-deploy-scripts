{ pkgs ? import (fetchGit {
    url = https://github.com/dapphub/dapptools.git;
    ref = dapptoolsRev;
  }) {}
, dapptoolsRev ? "d8e78aedaaeda323fb583ea52bef250634399e6a"
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
