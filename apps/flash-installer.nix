{ self, system, lib, writeShellApplication, ... }@pkgs:

with lib;

let
  inherit (self.inputs) nixpkgs;

  iso = nixpkgs.lib.nixosSystem { inherit system; specialArgs = { inherit self; }; modules = [ ../nixos/profiles/installer.nix ]; };
  # Build installer ISO
  isoPath = "${iso.config.system.build.isoImage}/iso/${iso.config.isoImage.isoName}";

in
getExe (writeShellApplication {
  name = "flash-installer";
  runtimeInputs = with pkgs; [ pv fzf ];

  text = ''
    # Select disk to flash
    # ———————————————————————————————→ This eqality checks for disks with removable tag (RM) ↓↓↓↓↓↓↓
    dev="/dev/$(lsblk -d -n --output RM,NAME,FSTYPE,SIZE,LABEL,TYPE,VENDOR,UUID | awk '{ if ($1 == 1) { print } }' | fzf | awk '{print $2}')"

    # Format selected disk
    pv -tpreb "${isoPath}" | sudo dd bs=4M of="$dev" iflag=fullblock conv=notrunc,noerror oflag=sync
  '';
})
