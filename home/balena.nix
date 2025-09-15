{
  config,
  lib,
  pkgs,
  ...
}: {
  # Shell aliases that work from any directory
  programs.zsh.shellAliases = {
    playground-eks = "nix develop ${config.home.homeDirectory}/.config/nix-darwin#playground";
    production-eks-old = "nix develop ${config.home.homeDirectory}/.config/nix-darwin#production-old";
    production-eks = "nix develop ${config.home.homeDirectory}/.config/nix-darwin#production-us";
    production-eks-eu = "nix develop ${config.home.homeDirectory}/.config/nix-darwin#production-eu";
    staging-eks = "nix develop ${config.home.homeDirectory}/.config/nix-darwin#staging-us";
    staging-eks-eu = "nix develop ${config.home.homeDirectory}/.config/nix-darwin#staging-eu";
  };

  programs.bash.shellAliases = {
    playground-eks = "nix develop ${config.home.homeDirectory}/.config/nix-darwin#playground";
    production-eks-old = "nix develop ${config.home.homeDirectory}/.config/nix-darwin#production-old";
    production-eks = "nix develop ${config.home.homeDirectory}/.config/nix-darwin#production-us";
    production-eks-eu = "nix develop ${config.home.homeDirectory}/.config/nix-darwin#production-eu";
    staging-eks = "nix develop ${config.home.homeDirectory}/.config/nix-darwin#staging-us";
    staging-eks-eu = "nix develop ${config.home.homeDirectory}/.config/nix-darwin#staging-eu";
  };
}
