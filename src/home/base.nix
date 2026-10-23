{
  flake.modules.homeManager.base = { osConfig, ... }: {
    config = {
      # Enable only if it was not loaded through the NixOS modules
      programs.home-manager.enable = osConfig == null;

      # Inherit the NixOS stateVersion
      home.stateVersion = if osConfig != null then osConfig.system.stateVersion else "26.05";

      # Reload system units when switching config
      systemd.user.startServices = "sd-switch";
    };
  };
}
