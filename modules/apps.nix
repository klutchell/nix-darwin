{pkgs, ...}: {
  ##########################################################################
  #
  #  Install all apps and packages here.
  #
  #  NOTE: Your can find all available options in:
  #    https://daiderd.com/nix-darwin/manual/index.html
  #
  # Feel free to modify this file to fit your needs.
  #
  ##########################################################################

  # Install packages from nix's official package repository.
  #
  # The packages installed here are available to all users, and are reproducible across machines, and are rollbackable.
  # But on macOS, it's less stable than homebrew.
  #
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  environment.systemPackages = with pkgs; [
    neovim
    git
  ];
  environment.variables.EDITOR = "nano";

  # To make this work, homebrew need to be installed manually, see https://brew.sh
  #
  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # 'zap': uninstalls all formulae(and related files) not listed here.
      cleanup = "zap";
    };

    # Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple account have records for them.
    # otherwise Apple Store will refuse to install them.
    # For details, see https://github.com/mas-cli/mas
    masApps = {
      # TODO Feel free to add your favorite apps here.

      # Xcode = 497799835;
      # Wechat = 836500024;
      # NeteaseCloudMusic = 944848654;
      # QQ = 451108668;
      # WeCom = 1189898970;  # Wechat for Work
      # TecentMetting = 1484048379;
      # QQMusic = 595615424;
      Bitwarden = 1352778147;
    };

    taps = [
      "homebrew/cask"
      "homebrew/cask-fonts"
      "homebrew/services"
      "homebrew/cask-versions"
    ];

    # `brew install`
    brews = [
      "wget" # download tool
      "aria2" # download tool
      "httpie" # http client
      "diffutils" # diff tool
      "mas" # Mac App Store CLI
      "bitwarden-cli" # The command line vault (Windows, macOS, & Linux).
      "ykman" # YubiKey manager
      "balena-cli" # The official balena CLI tool
      "rclone" # A command line utility for various operations on cloud storage.
    ];

    # `brew install --cask`
    casks = [
      "appcleaner"
      "balenaetcher"
      # "bartender"
      "brave-browser"
      "cloudflare-warp"
      "capacities"
      "chatgpt"
      "claude"
      "craft"
      "cryptomator"
      "cursor"
      "discord"
      "docker-desktop"
      "eloston-chromium"
      # "firefox"
      "google-drive"
      # "hyper"
      "kapitainsky-rclone-browser"
      "latest"
      "logi-options+"
      "macfuse"
      "magicquit"
      "ollama-app"
      "openvpn-connect"
      "protonvpn"
      # "raspberry-pi-imager"
      "raycast"
      "signal"
      "spotify"
      "tailscale-app"
      "visual-studio-code"
      "vlc"
      "warp"
      "yubico-yubikey-manager"
      "zoom"
      "zulip"
    ];
  };
}
