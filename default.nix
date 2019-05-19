# Default import pinned pkgs
{ pkgsSrc ? (import ./nix/pkgs.nix {}).pkgsSrc
, pkgsPin ? (import ./nix/pkgs.nix { inherit pkgsSrc; })
, pkgs ? pkgsPin.pkgs
, doCheck ? true
}: with pkgs;

let
  # Get contract dependencies from lock file
  inherit (callPackage ./nix/dapp.nix {}) specs packageSpecs;

  baseBins = [
    coreutils gnugrep gnused findutils
    bc jq
    solc
    dapp ethsign seth mcd-cli
  ];

  tdds = let
    deps' = lib.mapAttrs (_: v: v // { inherit doCheck; }) specs.this.deps;
    dss-deploy = import deps'.dss-deploy.src' {};

    # Create derivations from lock file data
    deps = builtins.attrValues (packageSpecs (deps' // {
      # Set specific solc versions for some contract derivations
      multicall = deps'.multicall // { solc = solc-versions.solc_0_4_25; };
      vote-proxy = deps'.vote-proxy // { solc = solc-versions.solc_0_4_25; };
      dss-deploy = dss-deploy.spec;
    }));
  in makerScriptPackage {
    name = "testchain-dss-deploy-scripts";
    src = lib.cleanSource (lib.sourceByRegex ./. [ "[^/]*" "(scripts|lib)/.*" ]);
    inherit deps;
    extraBins = [
      dss-deploy
    ];

    patchBin = writeScript "remove-cd" ''
      #!${stdenv.shell}
      exec ${perl}/bin/perl -pe '
        s|^(\s*)cd\s+(?:.*/)*([^/\n\r\s;&\|\.]+)|\1export DAPP_OUT=\$DAPP_LIB/\2/out;|;
        s|^(\s*)cd\s+[^\n\r;&\|]+|\1|;
        s|^(\s*)\./bin/||;
      '
    '';
  };
in {
  inherit tdds baseBins;
}
