let
  nixpkgsPin = import (fetchGit {
    url = "https://github.com/makerdao/nixpkgs-pin";
    ref = "master";
  });
  #import (../../nixpkgs-pin)
in

args:

let
  pkgsPin = nixpkgsPin args;
  pkgs = pkgsPin.pkgs;
in pkgsPin // {
    pkgs = pkgs // {
      # Add mcd-cli and sethret to local scope
      mcd-cli = pkgs.callPackage (import (fetchGit {
        url = https://github.com/makerdao/mcd-cli.git;
        rev = "86842b49defa53301ac0019f7d5994859bb3e1e9";
      })) {};

      sethret = (import (fetchGit {
        url = https://github.com/icetan/sethret.git;
        rev = "ef77915e2881011603491275f36b44bf2478b408";
      }) { inherit pkgs; }).sethret;
    };
  }
