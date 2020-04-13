rec {
  # Default import pinned pkgs
  makerpkgs = fetchGit {
    url = "https://github.com/makerdao/nixpkgs-pin";
    rev = "2aa4fe9d6337a7d6baa259f15f03b3d766bb0e50";
    ref = "simplify";
  };
}

