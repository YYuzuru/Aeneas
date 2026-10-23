#! /bin/bash

step3_deploy() {
	local repo=${1:?} qs_dir=${2:?} mode=${3:?}
	local -n items=${4:?}

	log "Step 3/4: deploying files ($mode)"
	local item
	for item in "${items[@]}"; do
		[[ -e $repo/$item ]] || die "'$item' is listed in ITEMS but missing from the repo"
	done
	rm -rf "$qs_dir" # safe: this directory is owned by this script
	mkdir -p "$qs_dir"
	for item in "${items[@]}"; do
		if [[ $mode == link ]]; then ln -s "$repo/$item" "$qs_dir/$item"
		else cp -r "$repo/$item" "$qs_dir/$item"; fi
	done
}
