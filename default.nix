# Default import pinned pkgs
{ pkgsSrc ? (import ./nix/pkgs.nix {}).pkgsSrc
, pkgs ? (import ./nix/pkgs.nix { inherit pkgsSrc; }).pkgs
, dss-deploy ? null
, doCheck ? true
}: with pkgs;

let
  # Get contract dependencies from lock file
  inherit (callPackage ./nix/dapp.nix {}) specs packageSpecs;
  inherit (specs.this) deps;

  # Import deploy scripts from dss-deploy
  dss-deploy' = if isNull dss-deploy
    then import deps.dss-deploy.src' {}
    else dss-deploy;

  # Create derivations from lock file data
  packages = packageSpecs (deps // {
    # Set specific solc versions for some contract derivations
    multicall = deps.multicall   // { solc = solc-versions.solc_0_4_25; };
    vote-proxy = deps.vote-proxy // { solc = solc-versions.solc_0_4_25; };
  });
in makerScriptPackage {
  name = "testchain-dss-deploy-scripts";

  # Specify files to add to build environment
  src = lib.sourceByRegex ./. [
    ".*deploy"
    ".*\.json"
    ".*scripts.*"
    ".*lib.*"
  ];

  solidityPackages = builtins.attrValues packages;

  extraBins = [
    dss-deploy'
  ];

  # Patch scripts by removing `cd` commands and `./bin/` from `dss-deploy`
  # script path.
  patchBin = writeScript "remove-cd" ''
    #!${stdenv.shell}
    exec ${perl}/bin/perl -pe '
      s|^(\s*)cd\s+[^\n\r;&\|]+|\1true|;
      s|^(\s*)\./bin/||;
    '
  '';
}
