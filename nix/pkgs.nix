let
  dapp-pkgs = import (fetchGit {
    url = "https://github.com/dapphub/dapptools";
    ref = "master";
  }) {};

  dapp-pkgs-0_16_0 = import (fetchGit {
    url = "https://github.com/dapphub/dapptools";
    ref = "dapp/0.16.0";
  }) {};
in dapp-pkgs // { inherit dapp-pkgs-0_16_0; }
