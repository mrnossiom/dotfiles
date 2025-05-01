{ self
, lib

, writeShellApplication
, ...
}@pkgs:

image-path:

lib.getExe (writeShellApplication {
  name = "flash-installer";
  runtimeInputs = with pkgs; [ pv fzf ];

  text = ''
    # Select disk to flash
    if [[ -n $"''${1-}" ]]; then
      dev="/dev/$1"
    else
      # —————————————————————————————— ↓↓ ———————————————→ Check disks with removable tag (RM) ↓↓↓↓↓↓↓
      dev="/dev/$(lsblk -d -n --output RM,NAME,FSTYPE,SIZE,LABEL,TYPE,VENDOR,UUID | awk '{ if ($1 == 1) { print } }' | fzf | awk '{print $2}')"
    fi

    echo "Flashing to $dev"
    
    # Format selected disk
    pv -tpreb "${image-path}" | sudo dd bs=4M of="$dev" iflag=fullblock conv=notrunc,noerror oflag=sync
  '';
})
