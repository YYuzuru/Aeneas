#! /bin/bash

check_hypr_version() {
	local min=${1:?min version required} have
	have=$(pacman -Q hyprland 2>/dev/null | awk '{print $2}' || true)
	[[ -z $have ]] && return 0 # not installed yet; step 2 will handle it
	((  $(vercmp "$have" "$min") >= 0 )) || die "Hyprland $have is older than $min"
}

step_check_system() {
	local min_hypr=${1:?min_hypr required}
  log "Step 0/4: checking system"
  [[ $EUID -ne 0 ]] || die "run as your normal user, not root (sudo is used only for pacman)"
  [[ -r /etc/os-release ]] || die "cannot read /etc/os-release"
  local id id_like
  id=$(. /etc/os-release && echo "${ID:-}")
  id_like=$(. /etc/os-release && echo "${ID_LIKE:-}")
  case $id in
  arch | cachyos) log "distro: $id" ;;
  *) if [[ $id_like == *arch* ]]; then
    warn "$id is Arch-based but untested; continuing"
  else
    die "only Arch and CachyOS are supported (found: ${id:-unknown})"
  fi ;;
  esac
  command -v pacman >/dev/null || die "pacman not found"
  check_hypr_version "$min_hypr"# skipped silently if Hyprland is not installed yet
}
