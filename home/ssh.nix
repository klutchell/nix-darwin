{...}: let
  # Local (this Mac) gpg-agent "extra" socket. This is the *restricted* socket:
  # it permits normal sign/decrypt but refuses key-management operations, which
  # makes it the safe one to forward. From `gpgconf --list-dir agent-extra-socket`.
  localGpgExtraSocket = "/Users/kyle/.gnupg/S.gpg-agent.extra";

  # A balena dev box reachable as `ssh misc<N>`, with our local SSH and GPG
  # agents forwarded so the remote can auth and sign (incl. via the YubiKey) as
  # if it were this machine.
  #
  # `remoteGpgSocket` is the remote's own gpg-agent socket path. On systemd
  # Linux it is /run/user/<UID>/gnupg/S.gpg-agent -- confirm the UID per host
  # with `ssh misc<N> id -u`. The RemoteForward replaces that socket with a
  # tunnel back to our local extra socket.
  #
  # Remote-side requirements (cannot be set from this repo):
  #   * sshd_config: `StreamLocalBindUnlink yes` so the forwarded socket
  #     replaces any stale one (otherwise the forward silently fails).
  #   * import the public key and set its owner-trust:
  #       gpg --recv-keys 0x38E0DD4F8A698F6A && \
  #         echo "0x38E0DD4F8A698F6A:6:" | gpg --import-ownertrust
  #   * git: `git config --global user.signingkey 0x38E0DD4F8A698F6A` and
  #     `commit.gpgsign true`.
  miscBox = remoteGpgSocket: name: {
    HostName = "${name}.dev.balena.io";
    User = "klutchell";
    ForwardAgent = true;
    RemoteForward = "${remoteGpgSocket} ${localGpgExtraSocket}";
  };
in {
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
        # Load the key into the agent on first use (passphrase from the macOS
        # Keychain) so it is present to be forwarded to misc1/misc2.
        AddKeysToAgent = "yes";
        UseKeychain = "yes";
      };
      # TODO(kyle): confirm each remote UID with `ssh misc<N> id -u`.
      "misc1" = miscBox "/run/user/1004/gnupg/S.gpg-agent" "misc1";
      "misc2" = miscBox "/run/user/1004/gnupg/S.gpg-agent" "misc2";
    };
  };
}
