#! /bin/bash

step_backup() {
  log "Step 1/4: backing up"
  local paths=()
  # -L catches a symlink left by a previous --link install
  if [[ -e $QS_DIR || -L $QS_DIR ]]; then paths+=("quickshell/$NAME"); fi
  if [[ -d $USER_DIR ]]; then paths+=("hypr/shell"); fi
  # Read-only copy for safety; this script never edits it.
  if [[ -f $CONFIG_HOME/hypr/hyprland.lua ]]; then paths+=("hypr/hyprland.lua"); fi
  if ((${#paths[@]} == 0)); then
    log "nothing to back up"
    return 0
  fi
  BACKUP_DIR="$REPO/.backup"
   mkdir -p "$BACKUP_DIR"
  local file
  file="$BACKUP_DIR/$(date +%F-%H-%M-%S).tar.gz"
  tar -czf "$file" -C "$CONFIG_HOME" "${paths[@]}"
  log "backup: $file"
}
