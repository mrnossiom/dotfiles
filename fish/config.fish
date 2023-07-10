set -l platform (uname)

fish_add_path \
    $HOME/.local/bin \
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
