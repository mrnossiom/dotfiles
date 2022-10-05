# TODO: ingore the `fish_variables` file and add abbr in here

# Init
set platform (uname)

# Common to all platforms
set -gx GPG_TTY (tty)

set fish_user_paths \
    $HOME/.bun/bin \
    $HOME/.config/yarn/global/node_modules/.bin/ \
    $HOME/.cargo/bin/ \
    $HOME/.local/bin \
    /usr/local/bin \
    /usr/local/sbin \
    /usr/local/opt/curl/bin

eval /home/milomoisson/miniconda3/bin/conda "shell.fish" hook $argv | source

# For Mac
if test $platform = Darwin
    # Nothing here yet.

    # For Linux
else if test $platform = Linux
    # Brew env setup
    test -d ~/.linuxbrew && eval (~/.linuxbrew/bin/brew shellenv)
    test -d /home/linuxbrew/.linuxbrew && eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)

    # Discord presence fix
    ln -sf {app/com.discordapp.Discord,$XDG_RUNTIME_DIR}/discord-ipc-0

    # For WSL
    if string match -r WSL (uname -r)
        # Nothing here yet.
    end
end

starship init fish | source
