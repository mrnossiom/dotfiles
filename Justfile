_default:
	@just --list --unsorted --list-heading '' --list-prefix '—— '

[linux]
switch:
	sudo nixos-rebuild switch --show-trace --flake .#

[macos]
switch:
	darwin-rebuild switch --show-trace --flake .#

[linux]
build:
	nixos-rebuild build --show-trace --flake .#

[macos]
build:
	darwin-rebuild build --show-trace --flake .#

check: build
	@unlink result

home-build PROFILE:
	home-manager build --show-trace --flake .#{{PROFILE}}

home-switch PROFILE:
	home-manager switch --show-trace --flake .#{{PROFILE}}
