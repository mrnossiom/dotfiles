#!/usr/bin/env bash
#* Check if brew is installed

if command -v brew &>/dev/null; then
    exit 0
fi

echo "Brew wasn't found. Tring to install"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
