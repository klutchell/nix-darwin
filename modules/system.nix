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

      NSGlobalDomain.AppleShowAllExtensions = true;
      NSGlobalDomain.AppleShowAllFiles = false;

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
