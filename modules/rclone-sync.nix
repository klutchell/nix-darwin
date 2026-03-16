{pkgs, ...}: let
  gdriveRemote = "gdrive:iCloud-Documents";

  filters = [
    ".DS_Store"
    ".Trash/**"
    "._*"
    "*.icloud"
    "~$*"
    "*.tmp"
    ".localized"
  ];

  filterArgs = builtins.concatStringsSep " " (map (f: "--filter '- ${f}'") filters);

  syncScript = pkgs.writeShellScript "rclone-bisync" ''
    set -euo pipefail

    ICLOUD_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Documents"
    GDRIVE_DIR="${gdriveRemote}"
    LOG_DIR="$HOME/.local/log"
    LOG_FILE="$LOG_DIR/rclone-bisync.log"

    mkdir -p "$LOG_DIR"

    log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"; }

    log "Starting iCloud ↔ Google Drive bisync"

    # Hydrate iCloud-evicted .icloud stub files
    find "$ICLOUD_DIR" -name '*.icloud' -print0 | while IFS= read -r -d "" f; do
      /usr/bin/brctl download "$(dirname "$f")/$(basename "$f" | sed 's/^\.//')"
      log "Hydrating: $f"
    done

    # Wait for hydration if any stubs were found
    if find "$ICLOUD_DIR" -name '*.icloud' -print0 | grep -qz .; then
      log "Waiting 15s for iCloud hydration..."
      sleep 15
    fi

    # Run bisync
    # NOTE: rclone.conf is NOT managed by nix — create it manually via `rclone config`
    if ${pkgs.rclone}/bin/rclone bisync "$ICLOUD_DIR" "$GDRIVE_DIR" \
      --check-access \
      --conflict-resolve newer \
      ${filterArgs} \
      >> "$LOG_FILE" 2>&1; then
      log "Bisync completed successfully"
    else
      EXIT_CODE=$?
      log "Bisync failed with exit code $EXIT_CODE"
      /usr/bin/osascript -e "display notification \"rclone bisync failed (exit $EXIT_CODE). Check ~/.local/log/rclone-bisync.log\" with title \"rclone bisync\""
      exit "$EXIT_CODE"
    fi
  '';
in {
  environment.systemPackages = [pkgs.rclone];

  launchd.user.agents.rclone-bisync = {
    serviceConfig = {
      Label = "com.kyle.rclone-bisync";
      ProgramArguments = ["${syncScript}"];
      StartInterval = 300;
      RunAtLoad = true;
      StandardOutPath = "/Users/kyle/.local/log/rclone-bisync-stdout.log";
      StandardErrorPath = "/Users/kyle/.local/log/rclone-bisync-stderr.log";
      EnvironmentVariables = {
        HOME = "/Users/kyle";
      };
    };
  };
}
