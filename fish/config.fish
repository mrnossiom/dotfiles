set platform (uname)

# For Mac
if test $platform = 'Darwin'
	# Nothing here yet...
# For Linux (or WSL)
else if test $platform = 'Linux'
	test -d ~/.linuxbrew && eval (~/.linuxbrew/bin/brew shellenv)
	test -d /home/linuxbrew/.linuxbrew && eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end

# Common to all platforms
set -gx GPG_TTY (tty)

starship init fish | source
