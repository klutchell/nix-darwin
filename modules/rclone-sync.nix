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

    # Prevent overlapping runs (launchd fires on a fixed interval regardless of
    # whether the prior run finished). macOS has no flock; use an atomic mkdir lock
    # with a PID file so a crashed run's lock can be reclaimed.
    LOCK="$LOG_DIR/.bisync.lock"
    if ! mkdir "$LOCK" 2>/dev/null; then
      if [ -f "$LOCK/pid" ] && ! kill -0 "$(cat "$LOCK/pid")" 2>/dev/null; then
        log "Reclaiming stale lock from dead PID $(cat "$LOCK/pid")"
        rm -rf "$LOCK"; mkdir "$LOCK"
      else
        log "Another bisync run is active — skipping this tick"
        exit 0
      fi
    fi
    echo $$ > "$LOCK/pid"
    trap 'rm -rf "$LOCK"' EXIT

    # Rotate the log if it grows past 10 MB (wc -c is POSIX-portable; avoids the
    # GNU-vs-BSD `stat` size-flag divergence on nix-darwin).
    if [ -f "$LOG_FILE" ] && [ "$(wc -c < "$LOG_FILE")" -gt 10485760 ]; then
      mv -f "$LOG_FILE" "$LOG_FILE.1"
    fi

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

    # Auto-resync ONLY when no prior bisync listings exist, with a 6h cooldown so a
    # failing resync can't re-fire a full-tree relisting every tick.
    #
    # rclone names listings <canonical-path1>..<canonical-path2>.path{1,2}.lst. The
    # local path's canonical form carries a backend prefix (e.g. `local__`) that varies
    # by rclone version, so glob for the gdrive pair rather than reconstructing the exact
    # name. The old reconstruction omitted the prefix, never matched, and forced a full
    # --resync on EVERY run (max API load — the opposite of what we want).
    BISYNC_STATE="$HOME/Library/Caches/rclone/bisync"
    RESYNC_COOLDOWN="$BISYNC_STATE/.last-resync-fail"
    RESYNC_FLAG=""
    HAVE_STATE=0
    for f in "$BISYNC_STATE"/*gdrive_.path1.lst; do
      if [ -s "$f" ]; then HAVE_STATE=1; fi
    done
    if [ "$HAVE_STATE" -eq 0 ]; then
      # In cooldown if the marker exists and is younger than 360 min. `find -mmin`
      # is identical on BSD (launchd PATH) and GNU, unlike `date -r FILE`.
      if [ -f "$RESYNC_COOLDOWN" ] && [ -z "$(find "$RESYNC_COOLDOWN" -mmin +360 2>/dev/null)" ]; then
        log "State missing but a resync failed < 6h ago — skipping to avoid storm"
        exit 0
      fi
      log "No prior bisync listings — running with --resync"
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
      --max-lock 2m \
      --tpslimit 6 \
      --tpslimit-burst 6 \
      --transfers 2 \
      --checkers 4 \
      --low-level-retries 20 \
      --drive-pacer-min-sleep 200ms \
      --local-no-check-updated \
      --drive-skip-gdocs \
      $RESYNC_FLAG \
      --filter '+ RCLONE_TEST' \
      --filter-from "$SYNCRC" \
      >> "$LOG_FILE" 2>&1; then
      log "Bisync completed successfully"
      rm -f "$RESYNC_COOLDOWN"
      # Clean empty subdirectories on both sides
      find "$ICLOUD_BASE" -mindepth 1 -type d -empty -delete 2>/dev/null || true
      $RCLONE rmdirs "$GDRIVE_BASE" --leave-root >> "$LOG_FILE" 2>&1 || true
    else
      EXIT_CODE=$?
      log "Bisync failed with exit code $EXIT_CODE"
      [ -n "$RESYNC_FLAG" ] && touch "$RESYNC_COOLDOWN"
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
      StartInterval = 1800;
      RunAtLoad = true;
      StandardOutPath = "/Users/kyle/.local/log/rclone-bisync-stdout.log";
      StandardErrorPath = "/Users/kyle/.local/log/rclone-bisync-stderr.log";
      EnvironmentVariables = {
        HOME = "/Users/kyle";
      };
    };
  };
}
