set -gp fish_user_paths '/usr/local/sbin' '~/.yarn/bin' '~/.config/yarn/global/node_modules/.bin'
set GPG_TTY (tty)

starship init fish | source
