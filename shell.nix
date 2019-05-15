{ pkgs ? import ./nix/pkgs.nix }: with pkgs;

let
  deploy = import ./. { inherit pkgs; };
in pkgs.mkShell {
  buildInputs = deploy.baseBins ++ [
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
