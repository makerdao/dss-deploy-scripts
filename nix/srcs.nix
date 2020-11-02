rec {
  # Default import pinned pkgs
  makerpkgs = fetchGit {
    url = "https://github.com/makerdao/makerpkgs";
    rev = "0cdc0e74ca1b4c2548d4eb36784ded03b416e8a6";
    ref = "master";
  };
}
