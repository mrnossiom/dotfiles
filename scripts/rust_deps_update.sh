#!/bin/bash
#* This scripts install all missing dependencies for rust.
#* Thanks to @nabijaczleweli on GitHub for the cargo-install-update cli and his help for this script.

cd $HOME

# If the .crates.toml file doesn't exist, exit with code 1
if [ ! -s ".cargo/.crates.toml" ]; then
	exit 1
fi

# Install all the missing binaries
cargo install-update -f $(
	# Dynamically create a script with awk to check if the corresponding binary exists
	awk -F= '/\((registry|git)\+/ {
		sub(/"/, "", $1);
		sub(/ .*/, "", $1);
		gsub(/[ "\[\]]/, "", $2);
		sub(/,$/, "", $2); split($2, b, ",");
		for(i = 1; i <= length(b); ++i) print "[ -x ~/.cargo/bin/" b[i] " ] || echo " $1
	}' .cargo/.crates.toml |

	# Execute the script and filter duplicates if any
	sh | uniq
)
