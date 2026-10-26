{
  self,
  inputs,
  withSystem,
  ...
}:
{
  flake.homeConfigurations.epita = withSystem "x86_64-linux" (
    { pkgs, upkgs, ... }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { osConfig = null; inherit upkgs; };
      modules = [
        ({ ... }: {
          imports = [
            inputs.stylix.homeModules.default

            self.modules.homeManager.base
            self.modules.homeManager.options
            self.modules.homeManager.agenix
            self.modules.homeManager.profile-lightweight
          ];

          config = {
            home.username = "milo.moisson";
            home.homeDirectory = "/home/milo.moisson";
          };
        })
      ];
    }
  );
}
