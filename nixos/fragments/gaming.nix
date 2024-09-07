{ ... }:

{
  config = {
    programs.steam = {
      enable = true;

      # Open ports in the firewall for Steam Remote Play and Source Dedicated Server
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };
}
