{ inputs, ... }:
{
  flake.modules.homeManager.sops = { config, ... }: {
    imports = [ inputs.sops-nix.homeManagerModules.sops ];

    config = {
      sops = {
        age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
      };
    };
  };
}
