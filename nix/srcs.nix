rec {
  # Default import pinned pkgs
  makerpkgs = fetchGit {
    url = "https://github.com/makerdao/makerpkgs";
    rev = "1a4820a5a4438046c0acbff3375570fe1d060bc4";
    ref = "master";
  };
}
