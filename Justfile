_default:
	@just --list --unsorted --list-heading '' --list-prefix '—— '

[linux]
switch PROFILE="" *ARGS:
	sudo nixos-rebuild switch --show-trace --flake .#{{PROFILE}} {{ARGS}}
[macos]
switch PROFILE="" *ARGS:
	darwin-rebuild switch --show-trace --flake .#{{PROFILE}} {{ARGS}}

[linux]
build PROFILE="" *ARGS:
	nixos-rebuild build --show-trace --flake .#{{PROFILE}} {{ARGS}}
[macos]
build PROFILE="" *ARGS:
	darwin-rebuild build --show-trace --flake .#{{PROFILE}} {{ARGS}}

home-build PROFILE *ARGS:
	home-manager build --show-trace --flake .#{{PROFILE}} {{ARGS}}

home-switch PROFILE *ARGS:
	home-manager switch --show-trace --flake .#{{PROFILE}} {{ARGS}}
