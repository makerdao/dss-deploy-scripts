{ pkgs ? import (fetchGit {
    url = https://github.com/dapphub/dapptools.git;
    ref = dapptoolsRev;
  }) {}
, dapptoolsRev ? "14138b7a2d29120beaca6e7754238d2640c25d45"
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
