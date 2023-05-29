set -l platform (uname)

fish_add_path \
    $HOME/go/bin \
    $HOME/.bun/bin \
    $HOME/.cargo/bin \
    $HOME/.local/bin \
    $HOME/.vector/bin \
    /usr/local/bin \
    /usr/local/sbin

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
set -U __fish_ls_command exa
set -U __fish_ls_color_opt '--color=auto'

source ~/.config/fish/fragments/abbreviations.fish
source ~/.config/fish/fragments/variables.fish
source ~/.config/fish/fragments/private_env.fish

starship init fish | source
