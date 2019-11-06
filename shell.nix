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
    ref = "v2.1.3";
    rev = "a82d8b06341a2fd53419831c6464006ecb8c8190";
  }) {};
in mkShell {
  buildInputs = tdds.bins ++ [
    tdds
    dapp2nix
    procps
  ];

  shellHook = ''
    export NIX_SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt

    setup-env() {
      . ${tdds}/lib/setup-env.sh
    }
    export -f setup-env
    setup-env || echo Re-run setup script with \'setup-env\'
  '';
}
