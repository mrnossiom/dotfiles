# PNPM
set -gx PNPM_HOME "/home/milomoisson/.local/share/pnpm"
set -gx PATH "$PNPM_HOME" $PATH

# Wasmer
export WASMER_DIR="/home/milomoisson/.wasmer"
[ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"

# `restic` Backup Tool
set -gx RESTIC_REPOSITORY /media/$USER/ArchaicBak/Backup

# allow git to use gpg
set -gx GPG_TTY (tty)

set -gx PROJECTS $HOME/Documents/Developement

# Add tools to path
fish_add_path \
    $HOME/go/bin \
    $HOME/.bun/bin \
    $HOME/.cargo/bin \
    $HOME/.vector/bin
