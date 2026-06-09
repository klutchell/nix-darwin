{ ... }: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [
      "~/.orbstack/ssh/config"
    ];
    settings = {
      "github.com" = {
        HostName = "github.com";
        IdentityFile = "~/.ssh/id_ed25519";
      };
      "misc1.dev.balena.io" = {
        HostName = "misc1.dev.balena.io";
        User = "klutchell";
      };
      "misc2.dev.balena.io" = {
        HostName = "misc2.dev.balena.io";
        User = "klutchell";
      };
    };
  };
}
