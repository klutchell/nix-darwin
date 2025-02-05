{pkgs, ...}: {
  home.packages = with pkgs; [
    nnn # terminal file manager

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    coreutils # GNU core utilities
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq
    gnugrep # GNU grep, egrep and fgrep

    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    # caddy
    gnupg

    # productivity
    glow # markdown previewer in terminal

    git-crypt # transparent file encryption in git
    hadolint # Dockerfile linter, validate inline bash scripts
    htop # interactive process viewer
    neofetch # A CLI system information tool written in BASH that supports displaying images.
    nodejs_22 # A JavaScript runtime built on Chrome's V8 JavaScript engine
    shellcheck # shell script analysis tool
    shfmt # A shell parser, formatter, and interpreter (POSIX/Bash/mksh)
    # yadm # Yet Another Dotfiles Manager

    arkade # Kubernetes apps installer
    alejandra # The Uncompromising Nix Code Formatter

    # bitwarden-cli # The command line vault (Windows, macOS, & Linux).

    actionlint # GitHub Actions linter

    pre-commit # A framework for managing and maintaining multi-language pre-commit hooks.

    # (callPackage ../pkgs/balena-cli.nix {})

    balena-cli # The official balena CLI tool

    (callPackage ../pkgs/go-github-apps.nix {})
  ];

  programs = {
    # modern vim
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
    };

    # A modern replacement for ‘ls’
    # useful in bash/zsh prompt, not in nushell.
    eza = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };

    # skim provides a single executable: sk.
    # Basically anywhere you would want to use grep, try sk instead.
    skim = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    gh = {
      enable = true;
      settings.git_protocol = "ssh";
      gitCredentialHelper.enable = true;
    };

    autojump = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    gpg = {
      enable = true;
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    go = {
      enable = true;
      goPath = "go";
      goBin = "go/bin";
    };
  };
}
