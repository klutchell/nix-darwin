{...} @ args:
#############################################################
#
#  Host & Users configuration
#
#############################################################
let
  hostname = "mercury";
  computerName = "Kyle's MacBook Pro";
  netbiosName = "MERCURY";
  username = "kyle";
in {
  networking.hostName = hostname;
  networking.computerName = computerName;
  system.defaults.smb.NetBIOSName = netbiosName;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;
  };

  nix.settings.trusted-users = [username];
}
