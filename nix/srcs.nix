rec {
  # Default import pinned pkgs
  makerpkgs = fetchGit {
    url = "https://github.com/makerdao/makerpkgs";
    rev = "2d3b57351735de0d36c8c20ce307a5ad2e4f4708";
    ref = "master";
  };
}

