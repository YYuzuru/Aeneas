#! /bin/bash
# ToDo:
#0. Check setup - Arch + CachyOs, Hyprland version (will not work for git-hyprland) relies on pacman
#1. backup
#2. check+install dependencies
#3. move git files
#4. update config

# -- 0. Check Setup --
set -euo pipefail

NAME="aeneas-shell"
REPO="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
QS_DIR="$CONFIG_HOME/quickshell/$NAME"
USER_DIR="$CONFIG_HOME/hypr/shell"
MIN_HYPR="0.56.0"

ITEMS=(shell.qml modules services components defaults)
REQUIRED_PKGS=(hyprland quickeshell)
OPTIONAL_PKGS=(qt6-declarative jq libnotify hyprpolkitagent ttf-jetbrains-mono-nerd)

MODE=copy
ASSUME_YES=0
SKIP_DEPS=0

usage() {
  echo "usage: $0 [--copy|--link] [--yes] [--no-deps]"
  echo "  --copy     copy files into place (default; tests the real install)"
  echo "  --link     symlink files from the repo (for development)"
  echo "  --yes      do not prompt before installing packages"
  echo "  --no-deps  skip the dependency step"
  exit "${1:-0}"
}
parse_args(){
	for arg in "$@"; do
	  case $arg in
	  --copy) MODE=copy ;;
	  --link) MODE=link ;;
	  -y | --yes) ASSUME_YES=1 ;;
	  --no-deps) SKIP_DEPS=1 ;;
	  -h | --help) usage 0 ;;
	  *) usage 2 ;;
	  esac
	done
}


source "$REPO/scripts/common.sh"
for f in common check backup deps deploy config; do
	source "$REPO/scripts/$f.sh"
done

parse_args "$@"

step_check_system "$MIN_HYPR"
step_backup "$CONFIG_HOME" "$REPO"
step_dependencies "$SKIP_DEPS" "$ASSUME_YES" "$MIN_HYPR" REQUIRED_PKGS OPTIONAL_PKGS
step_deploy "$REPO" "$QS_DIR" "$MODE" ITEMS
step_config "$REPO" "$USER_DIR"

echo "Running aeneas install script"

exit 0



step_config() {
  log "Step 4/4: updating config"
  mkdir -p "$USER_DIR"
  # Always refresh the reference copy, so users can diff it against theirs.
  cp "$REPO/defaults/config.json" "$USER_DIR/config.example.json"
  if [[ -f $REPO/lua/helper.lua ]]; then cp "$REPO/lua/helper.lua" "$USER_DIR/helper.lua"; fi

  local cfg="$USER_DIR/config.json"
  if [[ ! -f $cfg ]]; then
    cp "$REPO/defaults/config.json" "$cfg"
    log "created $cfg from defaults"
    return 0
  fi
  # Existing config: never rewrite it. Report problems and new keys only.
  if command -v jq >/dev/null; then
    if ! jq empty "$cfg" 2>/dev/null; then
      warn "$cfg is not valid JSON; the shell will keep its last good state or defaults"
      return 0
    fi
    local new
    new=$(jq -r -n --slurpfile d "$REPO/defaults/config.json" --slurpfile u "$cfg" \
      '($d[0] | keys) - ($u[0] | keys) | .[]')
    if [[ -n $new ]]; then
      log "new options not in your config (defaults apply until you add them):"
      printf '    %s\n' $new
    else
      log "your config has every top-level option"
    fi
  else
    log "kept existing $cfg (install jq to see new options)"
  fi
}

step_check_system
step_backup
step_dependencies
step_deploy
step_config

cat <<EOF

Done. Add this to your hyprland.lua yourself (this script never edits it):

  hl.on("hyprland.start", function() hl.exec_cmd("quickshell -c $NAME") end)

Try it now:  quickshell -c $NAME
EOF
