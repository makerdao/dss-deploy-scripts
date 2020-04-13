rec {
  # Default import pinned pkgs
  makerpkgs = fetchGit {
    url = "https://github.com/makerdao/nixpkgs-pin";
    rev = "116e8a2ef66e4f470fb7ceed1a4638ae7e995757";
    ref = "master";
  };
}

