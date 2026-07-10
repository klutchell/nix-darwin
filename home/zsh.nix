{
  pkgs,
  config,
  lib,
  ...
}: {
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

    profileExtra = ''
      # Add arkade binary directory to your PATH variable
      export PATH="$PATH:$HOME/.arkade/bin"
      export ACTUATED_URL="https://actuated-controller.o6s.io"
    '';

    initContent = lib.mkMerge [
      ''
        # # https://checkoway.net/musings/nix/
        # # Nix
        # if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        #   . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        # fi
        # # End Nix

        # worktrunk (wt) shell integration — enables directory switching on wt switch
        eval "$(wt config shell init zsh)"

        # safe-chain: wraps npm/yarn/pnpm/bun/pip/uv with supply-chain attack protection
        [ -f "$HOME/.cache/safe-chain/current/scripts/init-posix.sh" ] && source "$HOME/.cache/safe-chain/current/scripts/init-posix.sh"
      ''
      # Homebrew's `enableZshIntegration` runs `brew shellenv` from /etc/zshrc,
      # which is sourced before ~/.zshrc and prepends /opt/homebrew/bin to PATH.
      # Re-assert the nix profiles here — mkAfter pins this to the very end of
      # ~/.zshrc, so nix always wins regardless of how/when Homebrew is added.
      (lib.mkAfter ''
        export PATH="${config.home.profileDirectory}/bin:/run/current-system/sw/bin:$PATH"
      '')
    ];

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
