{pkgs, ...}:
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
