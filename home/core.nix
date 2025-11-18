{pkgs, ...}: {
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

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
    tio # simple TTY terminal I/O application

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
    nodejs_24 # A JavaScript runtime built on Chrome's V8 JavaScript engine
    shellcheck # shell script analysis tool
    shfmt # A shell parser, formatter, and interpreter (POSIX/Bash/mksh)
    # yadm # Yet Another Dotfiles Manager
    bun # Bun is a fast, modern package manager for JavaScript and TypeScript.

    arkade # Kubernetes apps installer
    alejandra # The Uncompromising Nix Code Formatter

    # bitwarden-cli # The command line vault (Windows, macOS, & Linux).

    actionlint # GitHub Actions linter
    pre-commit # A framework for managing and maintaining multi-language pre-commit hooks.

    # (callPackage ../pkgs/balena-cli/default.nix {})

    # balena-cli # The official balena CLI tool

    # (callPackage ../pkgs/go-github-apps.nix {})

    skopeo # A command line utility for various operations on container images and image repositories

    kubectl # Kubernetes command-line tool
    k9s # Kubernetes CLI to manage and view your clusters in a terminal UI

    uv # An extremely fast Python package and project manager, written in Rust
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

  services = {
    gpg-agent = {
      enable = true;
      # Configure gpg-agent to cache keys for 24 hours
      extraConfig = ''
        default-cache-ttl 86400
        max-cache-ttl 86400
      '';
    };
  };
}
