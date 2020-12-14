rec {
  # Default import pinned pkgs
  makerpkgs = fetchGit {
    url = "https://github.com/makerdao/makerpkgs";
    rev = "4d71760d27e88e244f9b5fe4d064b4c207b9b92d";
    ref = "master";
  };
}
