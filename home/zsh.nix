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
      # export BALENARC_NO_ANALYTICS=1
      # Add arkade binary directory to your PATH variable
      export PATH="$PATH:$HOME/.arkade/bin"
      export ACTUATED_URL="https://actuated-controller.o6s.io"
    '';

    initExtra = ''
      # # Nix
      # if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      #   . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      # fi
      # # End Nix
      export BALENARC_NO_ANALYTICS=1
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
      balena-staging = "BALENARC_BALENA_URL=balena-staging.com BALENARC_DATA_DIRECTORY=~/.balenaStaging balena";
      # gpt-review = "CONTEXT_FILE=${config.home.homeDirectory}/azure.yaml OPENAI_API_KEY=$(cat ${config.home.homeDirectory}/.openai_pat) gpt-review";
    };

    localVariables = {
      TZ = "America/Toronto";
      EDITOR = "nano";
      BALENARC_NO_ANALYTICS = "1";
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
