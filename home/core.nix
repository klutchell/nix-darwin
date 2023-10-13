{ pkgs, ... }:

{
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
    nodejs-18_x # A JavaScript runtime built on Chrome's V8 JavaScript engine
    shellcheck # shell script analysis tool
    shfmt # A shell parser, formatter, and interpreter (POSIX/Bash/mksh)
    # yadm # Yet Another Dotfiles Manager

    arkade # Kubernetes apps installer

    (callPackage ./balena-cli.nix { })
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
    exa = {
      enable = true;
      enableAliases = true;
      git = true;
      icons = true;
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
      enableGitCredentialHelper = true;
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
  };
}
