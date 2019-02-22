{ pkgs ? import (fetchGit {
    url = https://github.com/dapphub/dapptools.git;
    ref = dapptoolsRev;
  }) {}
, dapptoolsRev ? "ce05606a8e8f76bced691d6e03c8625862c17d97"
, eth_from
, eth_keystore ? ~/.dapp/testnet/8545/keystore
, eth_password ? "/dev/null"
}:

pkgs.mkShell {
  buildInputs = with pkgs; [ bc dapp ethsign seth ];

  ETH_FROM="${eth_from}";
  ETH_KEYSTORE="${eth_keystore}";
  ETH_PASSWORD="${eth_password}";
}
