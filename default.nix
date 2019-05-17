# Default import pinned pkgs
{ pkgsSrc ? (import ./nix/pkgs.nix {}).pkgsSrc
, pkgsPin ? (import ./nix/pkgs.nix { inherit pkgsSrc; })
, pkgs ? pkgsPin.pkgs
, doCheck ? true
}: with pkgs;

let
  # Get contract dependencies from lock file
  inherit (callPackage ./nix/dapp.nix {
    # Use HEVM from dapp/0.16.0 instead of latest for testing
    inherit (pkgsPin.pkgsVersions.dapp-0_16_0) dapp2;
  }) specs packageSpecs;

  baseBins = [
    coreutils gnugrep gnused findutils
    bc jq
    solc
    dapp ethsign seth mcd-cli
  ];

  tdds = let
    deps' = lib.mapAttrs (_: v: v // { inherit doCheck; }) specs.this.deps;
    # Create derivations from lock file data
    deps = builtins.attrValues (packageSpecs (deps' // {
      # Set specific solc versions for some contract derivations
      multicall = deps'.multicall // { solc = solc-versions.solc_0_4_25; };
      vote-proxy = deps'.vote-proxy // { solc = solc-versions.solc_0_4_25; };
    }));
    # Symlink all contract deps into one directory
    depsMerged = symlinkJoin {
      name = "deploy-script-deps";
      paths = deps;
    };
  in stdenv.mkDerivation {
    name = "testchain-dss-deploy-scripts";
    src = lib.cleanSource (lib.sourceByRegex ./. [ "[^/]*" "(scripts|lib)/.*" ]);
    buildInputs = [ makeWrapper perl ];
    buildPhase = "true";
    installPhase = ''
      find . -maxdepth 2 -type f -perm /111 ! -name "*.sh" | while read -r script; do
        dest=$out/bin/''${script#./}
        mkdir -p ''${dest%/*}

        perl -pe '\
          s|^(cd (?:.*/)*([^/\n\r]+))$|\1;export DAPP_OUT=\$DAPP_LIB/\2/out;|;
          s|^dapp .*build||;
        ' < $script > $dest
        chmod +x $dest

        wrapProgram $dest \
          --set PATH "${lib.makeBinPath baseBins}" \
          --set DAPP_SKIP_BUILD yes \
          --set DAPP_LIB ${depsMerged}/dapp
      done
      patchShebangs $out/bin

      find . -maxdepth 2 -type f -name "*.json" | while read -r config; do
        dest=$out/bin/''${config#./}
        mkdir -p ''${dest%/*}
        cp -v $config $dest
      done

      cp -rv lib $out/lib
    '';

    checkPhase = ''
      ${shellcheck}/bin/shellcheck $out/bin/*
    '';
  };
in {
  inherit tdds baseBins;
}
