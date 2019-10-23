{ pkgsSrc ? (import ./nix/pkgs.nix {}).pkgsSrc
, pkgs ? (import ./nix/pkgs.nix { inherit pkgsSrc dapptoolsOverrides; }).pkgs
, dapptoolsOverrides ? {}
, dss-deploy ? null
, doCheck ? false
, githubAuthToken ? null
}@args: with pkgs;

let
  tdds = import ./. args;
  dapp2nix = import (fetchGit {
    url = "https://github.com/icetan/dapp2nix";
    ref = "master";
    rev = "4905086d664b63921fc69be5d6ced1ea111d4463";
  }) {};
in mkShell {
  buildInputs = tdds.bins ++ [
    tdds
    dapp2nix
    procps
  ];

  shellHook = ''
    setup-env() {
      . ${tdds}/lib/setup-env.sh
    }
    export -f setup-env
    setup-env || echo Re-run setup script with \'setup-env\'
  '';
}
