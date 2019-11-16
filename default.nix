# Default import pinned pkgs
{ pkgsSrc ? (import ./nix/pkgs.nix {}).pkgsSrc
, pkgs ? (import ./nix/pkgs.nix { inherit pkgsSrc dapptoolsOverrides; }).pkgs
, dapptoolsOverrides ? {
  current = fetchGit {
    url = "https://github.com/icetan/dapptools";
    ref = "nix-solpkg-flatten";
    rev = "f34c2b30bce5e28ff8fbf9d1d16ef58f03127497";
  };
}
, dss-deploy ? null
, doCheck ? false
, githubAuthToken ? null
, srcRoot ? null
}: with pkgs;

let
  inherit (builtins) replaceStrings attrValues;
  inherit (lib) mapAttrs optionalAttrs id;
  # Get contract dependencies from lock file
  inherit (callPackage ./dapp2.nix { inherit srcRoot; }) specs packageSpecs package;
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
      (spec // {
        inherit doCheck;
        flatten = true;
      })
  ) deps);

  dss-proxy-actions-optimized = package (deps.dss-proxy-actions // {
    inherit doCheck;
    name = "dss-proxy-actions-optimized";
    solcFlags = "--optimize";
    flatten = true;
  });

  dss-flat = package (deps.dss-deploy.deps.dss // {
    inherit doCheck;
    name = "dss-flat";
    flatten = true;
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

  solidityPackages =
    (attrValues packages)
    ++ [
      dss-proxy-actions-optimized
      dss-flat
    ];

  extraBins = [
    dss-deploy'
  ];

  scriptEnv = {
    SKIP_BUILD = true;
  };
}
