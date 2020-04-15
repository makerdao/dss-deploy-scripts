rec {
  # Default import pinned pkgs
  makerpkgs = fetchGit {
    url = "https://github.com/makerdao/makerpkgs";
    rev = "9e2dd56cc50389d0b86eada965d1a9349a5735f0";
    ref = "master";
  };
}

