{ pkgs, lib, ... }:

with lib;

{
  config = {
    wayland.windowManager.sway.config.startup = [{
      command = "${getExe pkgs.workstyle} &> /tmp/workstyle.log";
      always = true;
    }];

    # We could've used `(pkgs.formats.toml { }).generate "config.toml" { <opts> }`
    # but this doesn't keep ordering, and ordering is important here
    xdg.configFile."workstyle/config.toml".source = ./config.toml;
  };
}
