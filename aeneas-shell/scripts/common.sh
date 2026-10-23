#! /bin/bash

log() { printf '==> %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}
confirm() {
  [[ $ASSUME_YES == 1 ]] && return 0
  local a
  read -r -p "$1 [y/N] " a
  [[ $a == [yY]* ]]
}

path_exists(){
	if [ ! -d $1 ]; then
		die "Path to '$1' folder does not exists"
		exit 1
	fi
}

folder_empty(){
	if [ -d $1 ]; then
		if [ ! -z "$(find $1 -mindepth 1 -maxdepth 1)"]; then
			die  "Folder is not empty '$1'"
			exit 1
		fi
	fi
}
