{ config
, lib
, ...
}:

let
  cfg = config.local.fragment.security;
in
{
  options.local.fragment.security.enable = lib.mkEnableOption ''
    Security related
  '';

  config = lib.mkIf cfg.enable {
    # Sudo
    security.sudo.enable = false;
    security.sudo-rs.enable = true;

    # Security Kits
    security.polkit.enable = true;
    security.rtkit.enable = true;

    # Systemd Login
    services.logind = {
      lidSwitch = "suspend";
      extraConfig = lib.generators.toKeyValue { } {
        IdleAction = "lock";
        # Don’t shutdown when power button is short-pressed
        HandlePowerKey = "lock";
        HandlePowerKeyLongPress = "suspend";
      };
    };

    # `swaylock` pam service must be at least declared to work properly
    security.pam.services."swaylock" = { };

    # reduce sudo fail delay to half a second
    security.pam.services."sudo" = { nodelay = true; failDelay = { enable = true; delay = 500000; }; };

    # Signing
    programs.gnupg.agent.enable = true;
    services.gnome.gnome-keyring.enable = true;

    # SSH
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    programs.ssh.startAgent = true;
  };
}
