{
  config,
  lib,
  pkgs,
  ...
}: {
  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  #
  #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -f ~/.gitconfig
  '';

  programs.git = {
    enable = true;
    # lfs.enable = true;
    package = pkgs.gitAndTools.gitFull;

    userName = "Kyle Harding";
    userEmail = "kyle@balena.io";

    ignores = [
      ".DS_Store"
      "*.pyc"
      "node_modules/"
      ".envrc"
      ".direnv*"
      ".devenv*"
    ];

    # includes = [
    #   {
    #     # use diffrent email & name for work
    #     path = "~/work/.gitconfig";
    #     condition = "gitdir:~/work/";
    #   }
    # ];

    extraConfig = {
      core = {
        editor = "nano";
      };
      color = {
        ui = true;
      };
      push = {
        default = "current";
        autoSetupRemote = true;
      };
      pull = {
        ff = "only";
        rebase = true;
      };
      init = {
        defaultBranch = "main";
      };
      sendemail = {
        from = "Kyle Harding <kyle@balena.io>";
        chainreplyto = false;
        smtpencryption = "tls";
        smtpserver = "smtp.gmail.com";
        smtpserverport = 587;
        smtpuser = "kyle@balena.io";
      };
    };

    signing = {
      key = "3EED528C8F97A819";
      signByDefault = true;
    };

    # https://nix-community.github.io/home-manager/options.html#opt-programs.git.delta.enable
    # https://github.com/dandavison/delta
    delta = {
      enable = true;
      # options = {
      #   features = "side-by-side";
      # };
    };

    aliases = {
      # common aliases
      br = "branch";
      co = "checkout";
      st = "status";
      ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate";
      ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";
      cm = "commit -m";
      ca = "commit -am";
      dc = "diff --cached";
      amend = "commit --amend '-S'";

      # aliases for submodule
      update = "submodule update --init --recursive";
      foreach = "submodule foreach";
    };
  };
}
