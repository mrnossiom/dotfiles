_default:
	@just --list --unsorted --list-heading '' --list-prefix '—— '

# Reload i3 and Regolith
reload-wm:
	regolith-look refresh

# Reload the notification manager `Dunst`
reload-dunst:
	pkill dunst
	@notify-send -u low "Low"
	@notify-send -u normal "Normal"
	@notify-send -u critical "Critical"

# Dump the current installed Brew packages to `Brewfile`
dump-brew:
	brew bundle dump --file others/Brewfile --force

# Dump the current installed APT packages to `apt-packages.txt`
dump-apt:
	apt-mark showmanual > apt-packages.txt

# Copy logid.cfg to /etc/logid.cfg
install-logid:
	sudo cp others/logid.cfg /etc/logid.cfg

# Uses the `RESTIC_REPOSITORY` environment variable to backup the home directory
backup-home:
	restic backup ~ --exclude-caches