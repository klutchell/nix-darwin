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
    package = pkgs.gitFull;

    ignores = [
      ".DS_Store"
      "*.pyc"
      "node_modules/"
      ".envrc"
      ".direnv*"
      ".devenv*"
      "devenv.*"
      ".env"
      ".cursor/"
      ".cursorrules"
      ".vscode/"
      ".claude/"
      "CLAUDE.md"
      "CLAUDE.local.md"
      ".beads/"
    ];

    # includes = [
    #   {
    #     # use diffrent email & name for work
    #     path = "~/work/.gitconfig";
    #     condition = "gitdir:~/work/";
    #   }
    # ];

    signing = {
      key = "0x38E0DD4F8A698F6A";
      signByDefault = true;
    };

    settings = {
      user = {
        name = "Kyle Harding";
        email = "kyle@balena.io";
      };
      alias = {
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
  };
}
