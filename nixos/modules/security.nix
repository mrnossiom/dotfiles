{ lib
, config
, pkgs
, ...
}:

with lib;

{
  config = {
    # Sudo
    security.sudo.enable = false;
    security.sudo-rs.enable = true;

    # Security Kits
    security.polkit.enable = true;
    security.rtkit.enable = true;

    # Systemd Login
    services.logind = {
      lidSwitch = "lock";
      lidSwitchDocked = "suspend";
      lidSwitchExternalPower = "lock";
      extraConfig = lib.generators.toKeyValue { } {
        IdleAction = "lock";
        # Don’t shutdown when power button is short-pressed
        HandlePowerKey = "lock";
        HandlePowerKeyLongPress = "suspend";
      };
    };

    security.pam.services.swaylock.text = "auth include login";

    # Signing
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    services.gnome.gnome-keyring.enable = true;

    # SSH
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };
}
