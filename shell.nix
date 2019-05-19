{ pkgsSrc ? (import ./nix/pkgs.nix {}).pkgsSrc
, pkgs ? (import ./nix/pkgs.nix { inherit pkgsSrc; }).pkgs
}: with pkgs;

let
  tdds = import ./. { inherit pkgs; };
in mkShell {
  buildInputs = tdds.bins ++ [
    tdds
    pkgs.sethret
  ];

  shellHook = ''
    setup-env() {
      . ${tdds}/lib/setup-env.sh
    }
    export -f setup-env
    setup-env || echo Re-run setup script with \'setup-env\'
  '';
}
