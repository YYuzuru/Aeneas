step_dependencies() {
  log "Step 2/4: checking dependencies"
  if [[ $SKIP_DEPS == 1 ]]; then
    log "skipped (--no-deps)"
    return 0
  fi
  local missing=() missing_opt=() p
  for p in "${REQUIRED_PKGS[@]}"; do pacman -Qq "$p" &>/dev/null || missing+=("$p"); done
  for p in "${OPTIONAL_PKGS[@]}"; do pacman -Qq "$p" &>/dev/null || missing_opt+=("$p"); done
  if ((${#missing[@]} == 0 && ${#missing_opt[@]} == 0)); then
    log "all dependencies present"
    return 0
  fi
  ((${#missing[@]})) && log "missing (required): ${missing[*]}"
  ((${#missing_opt[@]})) && log "missing (optional): ${missing_opt[*]}"
  if confirm "Install these with pacman?"; then
    # No -y on purpose: syncing the database without a full upgrade can cause
    # partial upgrades on Arch. If pacman reports a package as not found, run
    # `sudo pacman -Syu` yourself first.
    local flags=(--needed)
    [[ $ASSUME_YES == 1 ]] && flags+=(--noconfirm)
    sudo pacman -S "${flags[@]}" "${missing[@]}" "${missing_opt[@]}"
  elif ((${#missing[@]})); then
    die "required packages missing: ${missing[*]}"
  fi
}
