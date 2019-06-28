{ pkgsSrc ? (import ./nix/pkgs.nix {}).pkgsSrc
, pkgs ? (import ./nix/pkgs.nix { inherit pkgsSrc; }).pkgs
, dss-deploy ? null
, doCheck ? false
, githubAuthToken ? null
}@args: with pkgs;

let
  tdds = import ./. args;
in mkShell {
  buildInputs = tdds.bins ++ [
    tdds
    sethret
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
