_default:
	@just --list --unsorted --list-heading '' --list-prefix '—— '

[linux]
switch PROFILE="":
	sudo nixos-rebuild switch --show-trace --flake .#{{PROFILE}}

[macos]
switch PROFILE="":
	darwin-rebuild switch --show-trace --flake .#{{PROFILE}}

[linux]
build PROFILE="":
	nixos-rebuild build --show-trace --flake .#{{PROFILE}}

[macos]
build PROFILE="":
	darwin-rebuild build --show-trace --flake .#{{PROFILE}}

check PROFILE="": (build PROFILE)
	@unlink result

home-build PROFILE:
	home-manager build --show-trace --flake .#{{PROFILE}}

home-switch PROFILE:
	home-manager switch --show-trace --flake .#{{PROFILE}}
