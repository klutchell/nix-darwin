{
  pkgs,
  lib,
  ...
}: {
  system.stateVersion = 5;
  ids.gids.nixbld = 30000;

  # enable flakes globally
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Auto upgrade nix package and the daemon service.
  nix.enable = true;
  # nix.package = pkgs.nix;

  nixpkgs.overlays = [
    (final: prev: {
      inherit
        (prev.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
    # (import ./overlays/nodejs-patch.nix)
    # (import ./overlays/balena-cli.nix)
    # (self: super: {
    #   # https://github.com/NixOS/nixpkgs/issues/402079#issuecomment-2846741344
    #   nodejs = super.nodejs_22;
    #   nodejs-slim = super.nodejs-slim_22;
    # })
  ];

  nix.package = pkgs.lixPackageSets.stable.lix;

  programs.nix-index.enable = true;

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 1w";
  };

  # Manual optimise storage: nix-store --optimise
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.settings.auto-optimise-store = false;
}
