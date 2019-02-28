{ pkgs ? import (fetchGit {
    url = https://github.com/dapphub/dapptools.git;
    ref = dapptoolsRev;
  }) {}
, dapptoolsRev ? "a163a886ecdcfb84ae437a106d3bc72bd888ce4a"
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
