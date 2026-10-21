{
  config,
  pkgs,
  ...
}:
###################################################################################
#
#  macOS's System configuration
#
#  All the configuration options are documented here:
#    https://daiderd.com/nix-darwin/manual/index.html#sec-options
#
###################################################################################
{
  system = {
    # # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    # activationScripts.postUserActivation.text = ''
    #   # activateSettings -u will reload the settings from the database and apply them to the current session,
    #   # so we do not need to logout and login again to make the changes take effect.
    #   /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    # '';

    activationScripts.postActivation.text = ''
      sudo -u kyle /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

      # Make nix-installed binaries visible to GUI apps (Podman Desktop, Claude
      # Desktop, etc.). GUI apps inherit PATH from the launchd user domain, not
      # the shell. `launchd.user.envVariables` uses an ephemeral `launchctl
      # setenv` that runs only at switch and is wiped on reboot; instead we write
      # the persistent domain config, which survives reboots (applied at domain
      # bootstrap). Requires ONE reboot to take effect. Reversible: delete this
      # line and reboot.
      launchctl config user path "${builtins.concatStringsSep ":" [
        "/Users/kyle/.local/bin"
        "/etc/profiles/per-user/kyle/bin"
        "/run/current-system/sw/bin"
        "/nix/var/nix/profiles/default/bin"
        "/usr/local/bin"
        "/usr/bin"
        "/bin"
        "/usr/sbin"
        "/sbin"
      ]}" || true

      # Expose selected nix CLIs to GUI apps (Podman Desktop) that discover
      # tools by scanning /usr/local/bin, not $PATH. Symlinks are overwritten
      # each switch. Extend the list as needed.
      mkdir -p /usr/local/bin
      for b in podman kubectl kind; do
        ln -sf /etc/profiles/per-user/kyle/bin/$b /usr/local/bin/$b
      done
    '';

    primaryUser = "kyle";

    defaults = {
      ###############################################################################
      # General UI/UX                                                               #
      ###############################################################################

      menuExtraClock.Show24Hour = false; # show 24 hour clock

      ###############################################################################
      # Finder                                                                      #
      ###############################################################################

      NSGlobalDomain.AppleShowAllExtensions = true; # show all file extensions
      NSGlobalDomain.AppleShowAllFiles = false; # hide hidden files

      finder.FXDefaultSearchScope = "SCcf"; # search current folder
      finder.FXPreferredViewStyle = "Nlsv"; # list view
      finder.FXRemoveOldTrashItems = true; # remove old trash items

      finder.ShowPathbar = true; # show pathbar
      finder.ShowStatusBar = true; # show statusbar

      finder.ShowExternalHardDrivesOnDesktop = false;
      finder.ShowHardDrivesOnDesktop = false;
      finder.ShowMountedServersOnDesktop = false;
      finder.ShowRemovableMediaOnDesktop = false;

      ###############################################################################
      # Dock                                                                        #
      ###############################################################################

      dock.mineffect = "scale";
      dock.minimize-to-application = true;
      dock.show-process-indicators = true;
      dock.show-recents = false;

      ###############################################################################
      # Time Machine                                                                #
      ###############################################################################

      # Prevent Time Machine from prompting to use new hard drives as backup volume
      CustomUserPreferences."com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;

      # other macOS's defaults configuration.
      # ......
    };
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # eMudhra intermediate key compromise (https://emudhra.we-have-a-problem.com/).
  # Distrust the affected roots in /etc/ssl/certs/ca-certificates.crt
  # (NIX_SSL_CERT_FILE). Remove once nixpkgs cacert reaches NSS 3.131.1.
  security.pki.caCertificateBlacklist = [
    # nixpkgs cacert trusts this root for S/MIME only.
    "Comodo AAA Services root"
    # https://bugzilla.mozilla.org/show_bug.cgi?id=2084101
    "emSign ECC Root CA - G3"
    # https://bugzilla.mozilla.org/show_bug.cgi?id=2083709
    "emSign Root CA - C1"
    "emSign ECC Root CA - C3"
  ];

  # Apple's /usr/bin curl, git, and python3 read /etc/ssl/cert.pem, which
  # macOS does not update. Serve the same blacklisted Mozilla set. Use the
  # no-trust-rules bundle: a parser that ignores OpenSSL trust bits would
  # read a distrusted root in ca-bundle.crt as trusted.
  environment.etc."ssl/cert.pem" = {
    source = "${pkgs.cacert.override {
      blacklist = config.security.pki.caCertificateBlacklist;
    }}/etc/ssl/certs/ca-no-trust-rules-bundle.crt";
    # Apple's original file, and the copy with eMudhra roots removed by hand.
    knownSha256Hashes = [
      "9dae8d76e55cb08991f2b672d58999ea15560d910759c16b544f843bdffbb994"
      "94b80bc956443b8083230861b07f4cdb5170ef4a1f84970dabab3dd526aceb07"
    ];
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;
  # environment.shells = [
  #   pkgs.zsh
  # ];

  # # Fonts
  # fonts = {
  #   # use fonts specified by user rather than default ones
  #   fontDir.enable = true;

  #   fonts = with pkgs; [
  #     # icon fonts
  #     material-design-icons
  #     font-awesome

  #     # nerdfonts
  #     (nerdfonts.override {
  #       fonts = [
  #         "FiraCode"
  #         "JetBrainsMono"
  #         "Iosevka"
  #       ];
  #     })
  #   ];
  # };
}
