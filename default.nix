# Default import pinned pkgs
{ pkgsSrc ? (import ./nix/pkgs.nix {}).pkgsSrc
, pkgs ? (import ./nix/pkgs.nix { inherit pkgsSrc dapptoolsOverrides; }).pkgs
, dapptoolsOverrides ? {}
, dss-deploy ? null
, doCheck ? false
, githubAuthToken ? null
}: with pkgs;

let
  inherit (builtins) replaceStrings;
  inherit (lib) mapAttrs optionalAttrs id;
  # Get contract dependencies from lock file
  inherit (callPackage ./dapp2.nix {}) specs packageSpecs package;
  inherit (specs.this) deps;
  optinalFunc = x: fn: if x then fn else id;

  # Update GitHub repo URLs and add a auth token for private repos
  addGithubToken = spec: spec // (let
    url = replaceStrings
      [ "https://github.com" ]
      [ "https://${githubAuthToken}@github.com" ]
      spec.repo.url;
  in rec {
    repo = spec.repo // { inherit url; };
  });

  # Recursively add GitHub auth token to spec
  recAddGithubToken = spec: addGithubToken (spec // {
    deps = mapAttrs (_: recAddGithubToken) spec.deps;
  });

  # Import deploy scripts from dss-deploy
  dss-deploy' = if isNull dss-deploy
    then import (fetchGit deps.dss-deploy.repo) { inherit doCheck; }
    else dss-deploy;

  # Create derivations from lock file data
  packages = packageSpecs (mapAttrs (_: spec:
    (optinalFunc (! isNull githubAuthToken) recAddGithubToken)
      (spec // { inherit doCheck; })
  ) deps);
  
  dss-proxy-actions-optimized = package (deps.dss-proxy-actions // {
    inherit doCheck;
    name = "dss-proxy-actions-optimized";
    solcFlags = "--optimize";
  });

in makerScriptPackage {
  name = "dss-deploy-scripts";

  # Specify files to add to build environment
  src = lib.sourceByRegex ./. [
    "deploy-.*"
    ".*\.json"
    ".*scripts.*"
    ".*lib.*"
  ];

  solidityPackages = (builtins.attrValues packages) ++ [ dss-proxy-actions-optimized ];

  extraBins = [
    dss-deploy'
  ];

  scriptEnv = {
    SKIP_BUILD = true;
  };
}
