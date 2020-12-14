rec {
  # Default import pinned pkgs
  makerpkgs = fetchGit {
    url = "https://github.com/makerdao/makerpkgs";
    rev = "2f63f1a03c2773b92368f1f042b53187724bdcdc";
    ref = "fix-solc-versions";
  };
}
