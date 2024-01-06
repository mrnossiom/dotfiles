_default:
	@just --list --unsorted --list-heading '' --list-prefix '—— '

switch:
	sudo nixos-rebuild switch --show-trace

build:
	nixos-rebuild build --show-trace

check: build
	@ls result && unlink result

# TODO: custom rekey entry to rekey every secret avoiding to retype it everytime
