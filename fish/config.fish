# TODO: ingore the `fish_variables` file and add abbr in here

set platform (uname)

# Common to all platforms
set -gx GPG_TTY (tty)

set fish_user_paths \
    $HOME/.bun/bin \
    $HOME/.cargo/bin/ \
    $HOME/.local/bin \
    $HOME/.vector/bin \
    /usr/local/bin \
    /usr/local/sbin \
    /usr/local/opt/curl/bin

# pnpm
set -gx PNPM_HOME "/home/milomoisson/.local/share/pnpm"
set -gx PATH "$PNPM_HOME" $PATH
# pnpm end

# For Mac
if test $platform = Darwin
    # Nothing here yet.

    # For Linux
else if test $platform = Linux
    # Brew env setup
    test -d ~/.linuxbrew && eval (~/.linuxbrew/bin/brew shellenv)
    test -d /home/linuxbrew/.linuxbrew && eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    
    # See https://docs.conda.io/en/latest/miniconda.html#linux-installers for installation
    eval /home/milomoisson/miniconda3/bin/conda "shell.fish" hook $argv | source

    # Discord presence fix
    ln -sf {app/com.discordapp.Discord,$XDG_RUNTIME_DIR}/discord-ipc-0

    # For WSL
    if string match -r WSL (uname -r)
        # Nothing here yet.
    end
end

# Use exa instead of ls
set -U __fish_ls_command   'exa'
set -U __fish_ls_color_opt '--color=auto'

# Abbreviations
abbr -a !! --position anywhere --function last_history_item

abbr -a d docker
abbr -a dcu 'docker compose up -d'
abbr -a dcd 'docker compose down'

abbr -a rm 'rm -i'
abbr -a rmd 'rm -rd'

abbr -a c cargo
abbr -a b bun
abbr -a g git
abbr -a j just

abbr -a sl 'sl -Fal'
abbr -a clr ' clear'
abbr -a shutdown ' shutdown'
abbr -a clr ' clear'
abbr -a reboot ' reboot'
abbr -a history ' history'

abbr -a cp 'cp -iv'
abbr -a ln 'ln -v'
abbr -a mv 'mv -iv'
abbr -a mkdir 'mkdir -v'

abbr -a ls   'ls -F'
abbr -a la   'ls -Fa'
abbr -a ld   'ls -FD'
abbr -a ll   'ls -GlhF'
abbr -a lll  'ls -lhF'
abbr -a tree 'ls -T'

abbr -a grep rg
abbr -a cat bat
abbr -a diff delta

starship init fish | source
