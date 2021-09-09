#!/bin/bash

if ! command -v brew &> /dev/null

then
    echo "Brew wasn't found. Tring to install"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    exit
fi
