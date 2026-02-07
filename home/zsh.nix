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

    initContent = ''
      # # Nix
      # if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      #   . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      # fi
      # # End Nix
      export BALENARC_NO_ANALYTICS=1

      # Open or create a zellij dev session via zsm
      zdev() {
        if [ -n "$ZELLIJ" ]; then
          zellij action launch-or-focus-plugin "zsm" --floating
        else
          if [ -n "$1" ]; then
            local dir="''${1:-.}"
            dir="$(cd "$dir" 2>/dev/null && pwd)" || { echo "zdev: no such directory: $1"; return 1; }
            local name="''${2:-''${dir##*/}}"
            zellij attach "$name" -c options --default-cwd "$dir" --default-layout dev
          else
            zellij --layout dev
          fi
        fi
      }

      zls() { zellij list-sessions; }

      zkill() {
        if [ -n "$1" ]; then
          zellij kill-session "$1"
        else
          local pick
          pick=$(zellij list-sessions 2>/dev/null \
            | sed 's/\x1b\[[0-9;]*m//g' \
            | cut -d' ' -f1 \
            | fzf --prompt="kill session> " --height=~40%)
          [ -n "$pick" ] && zellij kill-session "$pick"
        fi
      }
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
      balena-testbot = "BALENARC_BALENA_URL=bm.balena-dev.com BALENARC_DATA_DIRECTORY=~/.balenaTestbot balena";
      balean = "balena";
    };

    localVariables = {
      TZ = "America/Toronto";
      EDITOR = "nvim";
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
