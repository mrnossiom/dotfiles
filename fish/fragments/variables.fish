# PNPM
set -gx PNPM_HOME "/home/milomoisson/.local/share/pnpm"
set -gx PATH "$PNPM_HOME" $PATH

# `restic` Backup Tool
set -gx RESTIC_REPOSITORY /media/$USER/ArchaicBak/Backup

# allow git to use gpg
set -gx GPG_TTY (tty)
