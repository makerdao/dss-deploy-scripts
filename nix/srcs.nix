rec {
  # Default import pinned pkgs
  makerpkgs = fetchGit {
    url = "https://github.com/makerdao/makerpkgs";
    rev = "281209b12e9e6eba42355f8b9037d0dfcc9089b2";
    ref = "master";
  };
}

