set -gp PATH '/usr/local/sbin' '~/.yarn/bin' '~/.config/yarn/global/node_modules/.bin'
set -g GPG_TTY (tty)

starship init fish | source
