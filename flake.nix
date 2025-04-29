{
  description = "Nix for macOS configuration";

  ##################################################################################################################
  #
  # Want to know Nix in details? Looking for a beginner-friendly tutorial?
  # Check out https://github.com/ryan4yin/nixos-and-flakes-book !
  #
  ##################################################################################################################

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    experimental-features = ["nix-command" "flakes"];

    substituters = [
      "https://cache.nixos.org"
    ];
  };

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # # https://github.com/jordanisaacs/homeage
    # homeage = {
    #   url = "github:jordanisaacs/homeage";
    #   inputs.nixpkgs.follows = "nixpkgs-darwin";
    # };

    # https://github.com/jordanisaacs/homeage/pull/43
    homeage = {
      url = "github:jordanisaacs/homeage/pull/43/head";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-2.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # The `outputs` function will return all the build results of the flake.
  # A flake can have many use cases and different types of outputs,
  # parameters in `outputs` are defined in `inputs` and can be referenced by their names.
  # However, `self` is an exception, this special parameter points to the `outputs` itself (self-reference)
  # The `@` syntax here is used to alias the attribute set of the inputs's parameter, making it convenient to use inside the function.
  outputs = inputs @ {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    homeage,
    lix-module,
    ...
  }: {
    darwinConfigurations.mercury = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin"; # change this to "aarch64-darwin" if you are using Apple Silicon
      modules = [
        ./modules/nix-core.nix
        ./modules/system.nix
        ./modules/apps.nix
        ./modules/host-users.nix

        # home manager
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = inputs;
          home-manager.users.kyle = import ./home;
        }

        lix-module.nixosModules.default
      ];
    };

    # nix code formmater
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
  };
}
