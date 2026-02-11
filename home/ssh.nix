{ ... }: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [
      "~/.orbstack/ssh/config"
    ];
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        identityFile = "~/.ssh/id_ed25519";
      };
      "misc1.dev.balena.io" = {
        hostname = "misc1.dev.balena.io";
        user = "klutchell";
      };
      "misc2.dev.balena.io" = {
        hostname = "misc2.dev.balena.io";
        user = "klutchell";
      };
    };
  };
}
