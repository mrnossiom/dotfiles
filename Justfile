_default:
	@just --list --unsorted --list-heading '' --list-prefix '—— '

[linux]
switch profile="" *args:
	sudo nixos-rebuild switch --show-trace --flake .#{{profile}} {{args}}
[macos]
switch profile="" *args:
	darwin-rebuild switch --show-trace --flake .#{{profile}} {{args}}

[linux]
build profile="" *args:
	nixos-rebuild build --show-trace --flake .#{{profile}} {{args}}
[macos]
build profile="" *args:
	darwin-rebuild build --show-trace --flake .#{{profile}} {{args}}

home-build profile *args:
	home-manager build --show-trace --flake .#{{profile}} {{args}}

home-switch profile *args:
	home-manager switch --show-trace --flake .#{{profile}} {{args}}

switch-target profile host *args:
	nixos-rebuild switch \
		--flake .#{{profile}} \
		--target-host {{host}} \
		--use-remote-sudo {{args}}
