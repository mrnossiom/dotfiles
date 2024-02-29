{ lib
, config
, pkgs
, ...
}:

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
      # TODO: fix issues on neo laptop
      lidSwitch = "suspend";
      extraConfig = lib.generators.toKeyValue { } {
        IdleAction = "lock";
        # Don’t shutdown when power button is short-pressed
        HandlePowerKey = "lock";
        HandlePowerKeyLongPress = "suspend";
      };
    };

    # Required when using swaylock
    security.pam.services."swaylock" = { };

    # Signing
    programs.gnupg.agent.enable = true;
    services.gnome.gnome-keyring.enable = true;

    programs.ssh.startAgent = true;

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
