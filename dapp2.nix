{ solidityPackage, solc, hevm, dapp2, srcRoot ? null }:

let
  inherit (builtins) map listToAttrs attrNames attrValues length fromJSON readFile;
  mapAttrs = if (builtins ? mapAttrs)
    then builtins.mapAttrs
    else f: attrs:
      listToAttrs (map
        (name: { inherit name; value = f name attrs."${name}"; })
        (attrNames attrs));

  defaults = {
    inherit solc hevm;
    test-hevm = dapp2.test-hevm;
    doCheck = true;
  };

  package = spec: let
    spec' = defaults // (removeAttrs spec [ "repo" ]);
    deps = map (spec:
      package (spec // { inherit (spec') solc test-hevm hevm doCheck; })
    ) (attrValues spec'.deps);
  in solidityPackage (spec' // { inherit deps; });

  packageSpecs = mapAttrs (_: package);

  jsonSpecs = fromJSON (readFile ./.dapp.json);

  resolveDeps = root: _: v:
    let
      contract = jsonSpecs.contracts."${v}";
      contract' = contract // {
        src = if (srcRoot == null)
          then "${fetchGit contract.repo}/src"
          else "${srcRoot}/${root}/${contract.name}/src";
      };
      noDeps = length (attrNames contract.deps) == 0;
    in
      if noDeps
      then contract'
      else contract' // {
        deps = mapAttrs
          (resolveDeps "${root}/${contract.name}/lib")
          contract.deps;
      };

  specs = (mapAttrs resolveDeps jsonSpecs.contracts) // {
    this = jsonSpecs.this // {
      src = ./.;
      deps = mapAttrs (resolveDeps ".") jsonSpecs.this.deps;
    };
  };
in {
  inherit package packageSpecs specs;
  this = package specs.this;
  deps = packageSpecs specs.this.deps;
}
