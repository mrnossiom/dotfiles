# My computers and servers (mostly nix) configuration

## Options

```nix
# in a NixOS module
{
	local.ports."<name>" = 4242; # Shorthand
	local.ports."<name>" = {
		number = 4242;
		string = "4242"; # Read-only
		public = true; # Opens firewall depending on tcp/udp value
		tcp = true;
		udp = false;
	};
}
```

```nix
# in a Home Manager module
{
	local.flags = {
		onlyCached = true; # dictate if you prefer to use cached pkgs
		useZen = true; # use the Zen fork or vanilla Firefox
	};
}
```

## Bootstrap lightweight home-manager config

```sh
nix run nixpkgs#home-manager -- switch --flake .#lightweight
```

## Make a backup

Pull up your favorite ArchaicBackup disc

- Set environment variables

	`RESTIC_REPOSITORY`: `/run/media/user/discname/`
	`RESTIC_PASSWORD_FILE`: ?

- Initialize repository

	```sh
	restic init --repo /srv/restic-repo
	```

## Deploy server

```sh
nixos-anywhere --flake .#weird-row user@ip

nixos-rebuild switch \
	--flake .#weird-row \
	--target-host user@ip \
	--use-remote-sudo
```

## LUKS reminders

- [Backup and Restore LUKS header](https://wiki.archlinux.org/title/Dm-crypt/Device_encryption#Backup_and_restore)

---

Milo Moisson © 2023-2027
