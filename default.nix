# Default import pinned pkgs
{ pkgs ? import ./nix/pkgs.nix }:

# Add mcd-cli and sethret to local scope
with (pkgs // {
  mcd-cli = pkgs.callPackage (import (fetchGit {
    url = https://github.com/makerdao/mcd-cli.git;
    rev = "86842b49defa53301ac0019f7d5994859bb3e1e9";
  })) {};

  sethret = (import (fetchGit {
    url = https://github.com/icetan/sethret.git;
    rev = "ef77915e2881011603491275f36b44bf2478b408";
  }) {}).sethret;
});

let
  # Get contract dependencies from lock file
  inherit (callPackage ./nix/dapp.nix {
    inherit (pkgs.dapp-pkgs-0_16_0) dapp2;
  }) specs packageSpecs;

  baseBins = [
    coreutils gnugrep gnused findutils
    solc
    dapp ethsign seth mcd-cli sethret
    bc jq procps
  ];

  tdds = let
    deps' = specs.this.deps;
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
    src = lib.cleanSource (lib.sourceByRegex ./. [ "^[^/]*$" ]);
    buildInputs = [ makeWrapper perl ];
    buildPhase = "true";
    installPhase = ''
      find . -maxdepth 2 -type f -executable ! -name "*.sh" | while read -r script; do
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
