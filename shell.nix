{ pkgsSrc ? (import ./nix/pkgs.nix {}).pkgsSrc
, pkgs ? (import ./nix/pkgs.nix { inherit pkgsSrc; }).pkgs
}: with pkgs;

let
  deploy = import ./. {
    inherit pkgs;
    doCheck = false;
  };
in mkShell {
  buildInputs = deploy.baseBins ++ [
    pkgs.sethret
    deploy.tdds
  ];

  shellHook = ''
    setup-env() {
      . ${./scripts/setup-env.sh}
    }
    export -f setup-env
    setup-env || echo Re-run setup script with \'setup-env\'
  '';
}
