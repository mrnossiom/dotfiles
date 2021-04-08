# Init
set platform (uname)

# Common to all platforms
set -gx GPG_TTY (tty)

set fish_user_paths \
	$HOME/.config/yarn/global/node_modules/.bin/ \
	$HOME/.cargo/bin/

# For Mac
if test $platform = 'Darwin'
	# Nothing here yet...
# For Linux 
else if test $platform = 'Linux'
	test -d ~/.linuxbrew && eval (~/.linuxbrew/bin/brew shellenv)
	test -d /home/linuxbrew/.linuxbrew && eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)

	# For WSL
	if string match -r WSL (uname -r)
		# Nothing here yet...
	end
end

starship init fish | source
