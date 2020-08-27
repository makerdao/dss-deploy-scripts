let srcs = import ./nix/srcs.nix; in

{ pkgs ? import srcs.makerpkgs { inherit dapptoolsOverrides; }
, dapptoolsOverrides ? {}
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

  # Update dependency specs with default values
  deps' = (mapAttrs (_: spec:
    (optinalFunc (! isNull githubAuthToken) recAddGithubToken)
      (spec // {
        inherit doCheck;
        solc = solc-versions.solc_0_5_12;
      })
  ) deps);

  # Create derivations from lock file data
  packages = packageSpecs (deps' // {
    # Package overrides
    ilk-registry = deps'.ilk-registry           // { name = "ilk-registry-optimized";      solcFlags = "--optimize --optimize-runs 1000000"; solc = solc-versions.solc_0_6_7; };
    dss-proxy-actions = deps'.dss-proxy-actions // { name = "dss-proxy-actions-optimized"; solcFlags = "--optimize"; };
    dss-deploy-optimized = deps'.dss-deploy     // { name = "dss-deploy-optimized";        solcFlags = "--optimize"; };
  });

in makerScriptPackage {
  name = "dss-deploy-scripts";

  # Specify files to add to build environment
  src = lib.sourceByRegex ./. [
    "bin" "bin/.*"
    "lib" "lib/.*"
    "libexec" "libexec/.*"
    "config" "config/.*"
  ];

  solidityPackages = builtins.attrValues packages;
}
