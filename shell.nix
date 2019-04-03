{ pkgs ? import (fetchGit {
    url = https://github.com/dapphub/dapptools.git;
    rev = "6943c76bfb8e0b1fce54c3d9bba6f0f7e50d2f5c";
  }) {}
, mcd-cli ? pkgs.callPackage (import (fetchGit {
    url = https://github.com/makerdao/mcd-cli.git;
    rev = "86842b49defa53301ac0019f7d5994859bb3e1e9";
  })) {}
, sethret ? (import (fetchGit {
    url = https://github.com/icetan/sethret.git;
    rev = "ef77915e2881011603491275f36b44bf2478b408";
  }) {}).sethret
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    dapp ethsign seth mcd-cli sethret
    bc jq coreutils findutils procps
  ];

  shellHook = ''
    setup-env() {
      . ${./scripts/setup-env.sh}
    }
    export -f setup-env
    setup-env || echo Re-run setup script with \'setup-env\'
  '';
}
