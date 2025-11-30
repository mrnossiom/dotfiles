flake-lib: pkgs:

let
  keys = import ./secrets/keys.nix;
in
{
  nixosConfigurations = with flake-lib.nixos; {
    # Desktops
    "neo-wiro-laptop" = createSystem pkgs [
      (system "neo-wiro-laptop" "laptop")
      (managedDiskLayout "luks-btrfs" { device = "nvme0n1"; swapSize = 12; })
      (user "milomoisson" { description = "Milo Moisson"; profile = "desktop"; keys = keys.users; })
    ];

    "archaic-wiro-laptop" = createSystem pkgs [
      (system "archaic-wiro-laptop" "laptop")
      (user "milomoisson" { description = "Milo Moisson"; profile = "desktop"; keys = keys.users; })
    ];

    # Servers
    "weird-row-server" = createSystem pkgs [
      (host "weird-row-server")
      (managedDiskLayout "ext4-hetzner" { device = "sda"; swapSize = 2; })
      # TODO: should we keep a real user there?
      (user "milomoisson" { description = "Milo Moisson"; profile = "server"; keys = keys.users; })
    ];
  };

  # I bundle my Home Manager config via the NixOS modules which create system generations and give free rollbacks.
  # However, in non-NixOS contexts, you can still use Home Manager to manage dotfiles using this template.
  homeConfigurations = with flake-lib.home-manager; {
    "epita" = createHome pkgs [
      (home "milo.moisson" "/home/milo.moisson" "lightweight")
    ];
  };

  darwinConfigurations = with flake-lib.darwin; {
    "apple-wiro-laptop" = createSystem pkgs [
      (system "apple-wiro-laptop" "macintosh")
      (user "milomoisson" { description = "Milo Moisson"; profile = "macintosh"; keys = keys.users; })
    ];
  };
}
