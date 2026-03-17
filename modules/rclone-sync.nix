{pkgs, ...}: let
  gdriveRemote = "gdrive:";
  rclone = "${pkgs.rclone}/bin/rclone";

  syncScript = pkgs.writeShellScript "rclone-bisync" ''
    set -euo pipefail

    ICLOUD_BASE="/Users/kyle/Library/Mobile Documents/com~apple~CloudDocs/Documents"
    GDRIVE_BASE="${gdriveRemote}"
    SYNCRC="$ICLOUD_BASE/.syncrc"
    LOG_DIR="$HOME/.local/log"
    LOG_FILE="$LOG_DIR/rclone-bisync.log"
    RCLONE="${rclone}"

    mkdir -p "$LOG_DIR"

    log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"; }

    # Require .syncrc to exist
    if [ ! -f "$SYNCRC" ]; then
      log "No .syncrc found — nothing to sync"
      exit 0
    fi

    # Ensure RCLONE_TEST exists on both sides for --check-access
    [ -f "$ICLOUD_BASE/RCLONE_TEST" ] || touch "$ICLOUD_BASE/RCLONE_TEST"
    $RCLONE cat "$GDRIVE_BASE/RCLONE_TEST" >/dev/null 2>&1 || \
      $RCLONE touch "$GDRIVE_BASE/RCLONE_TEST" 2>/dev/null || true

    # Hydrate iCloud-evicted .icloud stubs across entire tree
    HYDRATED=0
    find "$ICLOUD_BASE" -name '*.icloud' -print0 | while IFS= read -r -d "" f; do
      /usr/bin/brctl download "$(dirname "$f")/$(basename "$f" | sed 's/^\.//')"
      log "Hydrating: $f"
      HYDRATED=1
    done

    if find "$ICLOUD_BASE" -name '*.icloud' -print0 | grep -qz .; then
      log "Waiting 15s for iCloud hydration..."
      sleep 15
    fi

    # Auto-resync if state files are missing
    BISYNC_STATE="$HOME/Library/Caches/rclone/bisync"
    STATE_KEY=$(echo "''${ICLOUD_BASE}..''${GDRIVE_BASE}" | sed 's|^/||; s|[/ :]|_|g')
    RESYNC_FLAG=""
    if [ ! -f "$BISYNC_STATE/$STATE_KEY.path1.lst" ] || [ ! -f "$BISYNC_STATE/$STATE_KEY.path2.lst" ]; then
      log "No prior state files — running with --resync"
      RESYNC_FLAG="--resync"
    fi

    log "Starting bisync: $ICLOUD_BASE ↔ $GDRIVE_BASE"

    # Single root-level bisync with .syncrc as filter
    # CLI --filter runs before --filter-from, so RCLONE_TEST is always included
    if $RCLONE bisync "$ICLOUD_BASE" "$GDRIVE_BASE" \
      --check-access \
      --conflict-resolve newer \
      --resilient \
      --recover \
      $RESYNC_FLAG \
      --filter '+ RCLONE_TEST' \
      --filter-from "$SYNCRC" \
      >> "$LOG_FILE" 2>&1; then
      log "Bisync completed successfully"
      # Clean empty subdirectories on both sides
      find "$ICLOUD_BASE" -mindepth 1 -type d -empty -delete 2>/dev/null || true
      $RCLONE rmdirs "$GDRIVE_BASE" --leave-root >> "$LOG_FILE" 2>&1 || true
    else
      EXIT_CODE=$?
      log "Bisync failed with exit code $EXIT_CODE"
      /usr/bin/osascript -e "display notification \"rclone bisync failed (exit $EXIT_CODE). Check ~/.local/log/rclone-bisync.log\" with title \"rclone bisync\""
      exit 1
    fi
  '';
in {
  environment.systemPackages = [pkgs.rclone];

  launchd.user.agents.rclone-bisync = {
    serviceConfig = {
      Label = "com.kyle.rclone-bisync";
      ProgramArguments = ["${syncScript}"];
      StartInterval = 600;
      RunAtLoad = true;
      StandardOutPath = "/Users/kyle/.local/log/rclone-bisync-stdout.log";
      StandardErrorPath = "/Users/kyle/.local/log/rclone-bisync-stderr.log";
      EnvironmentVariables = {
        HOME = "/Users/kyle";
      };
    };
  };
}
