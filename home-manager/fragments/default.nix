{
  # Provides the NixOS configuration if HM was loaded through the NixOS module
  osConfig ? null
, ...
}:

{
  imports = [
    ./agenix.nix
    ./aws.nix
    ./chromium.nix
    ./epita.nix
    ./firefox.nix
    ./foot.nix
    ./git.nix
    ./helix.nix
    ./imv.nix
    ./jujutsu.nix
    ./kitty.nix
    ./rust.nix
    ./shell.nix
    ./thunderbird.nix
    ./tools.nix
    ./vm-bar.nix
    ./vm-compose.nix
    ./vm.nix
    ./vm-search.nix
    ./vscodium.nix
    ./xdg-mime.nix
    ./zellij
  ];

  config = {
    programs.home-manager.enable = osConfig == null;

    home.stateVersion =
      if osConfig != null
      then osConfig.system.stateVersion
      else "24.05";

    # Reload system units when switching config
    systemd.user.startServices = "sd-switch";
  };
}
