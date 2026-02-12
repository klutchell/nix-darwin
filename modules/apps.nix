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
    git
  ];

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
      Dropover = 1355679052;
      Hyperspace = 6739505345;
      Parachute = 6748614170;
      # Perplexity = 6714467650;
      SaveToRaindrop = 1549370672;
      SaveToReader = 1640236961;
      SimpleLoginForSafari = 6475835429;
      # FolderPreview = 6698876601;
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
      # "bitwarden-cli" # The command line vault (Windows, macOS, & Linux).
      "ykman" # YubiKey manager
      "rclone" # A command line utility for various operations on cloud storage.
      "worktrunk" # Git worktree management CLI
      # "bd" # A memory upgrade for your coding agent
    ];

    # `brew install --cask`
    casks = [
      # # https://nikitabobko.github.io/AeroSpace/guide#installation
      # "nikitabobko/tap/aerospace"
      # "alcove"
      "antigravity"
      "appcleaner"
      "balenaetcher"
      "brave-browser"
      "cloudflare-warp"
      "capacities"
      # "chatgpt"
      "claude"
      "claude-code"
      "craft"
      "cryptomator"
      "docker-desktop"
      "ungoogled-chromium"
      "ghostty"
      "google-drive"
      "hazel"
      "iina"
      "jordanbaird-ice"
      # "logi-options+"
      "macfuse"
      "magicquit"
      "ollama-app"
      "openvpn-connect"
      "orbstack"
      "pronotes"
      "protonvpn"
      "raycast"
      "setapp"
      "signal"
      "spotify"
      "tailscale-app"
      "visual-studio-code"
      # "vlc"
      "yubico-yubikey-manager"
      "zoom"
    ];
  };
}
