{pkgs, ...}: {
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    # syntaxHighlighting = {
    #   enable = true;
    # };
    syntaxHighlighting.enable = true;

    autocd = true;

    # # https://checkoway.net/musings/nix/
    # envExtra = ''
    #   [[ -o login ]] && export PATH='/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin'
    # '';

    # https://checkoway.net/musings/nix/
    profileExtra = ''
      # Set PATH, MANPATH, etc., for Homebrew.
      eval "$(/opt/homebrew/bin/brew shellenv)"
      # export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"
      # Add arkade binary directory to your PATH variable
      export PATH="$PATH:$HOME/.arkade/bin"
      export ACTUATED_URL="https://actuated-controller.o6s.io"
    '';

    initContent = ''
      # # Nix
      # if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      #   . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      # fi
      # # End Nix
      # worktrunk (wt) shell integration — enables directory switching on wt switch
      eval "$(wt config shell init zsh)"
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "docker"
        "gh"
        "git"
        "direnv"
      ];
      theme = "robbyrussell";
    };

    shellAliases = {
      # ll = "ls -l";
      # hms = "home-manager switch";
      zj = "zellij --layout session-picker";
      balena-staging = "BALENARC_BALENA_URL=balena-staging.com BALENARC_DATA_DIRECTORY=~/.balenaStaging balena";
      balena-testbot = "BALENARC_BALENA_URL=bm.balena-dev.com BALENARC_DATA_DIRECTORY=~/.balenaTestbot balena";
      balean = "balena";
    };

    localVariables = {
      TZ = "America/Toronto";
      EDITOR = "nvim";
    };

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.5.0";
          sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
        };
      }
    ];
  };
}
