{
  self,
  inputs,
  withSystem,
  ...
}:
{
  flake.homeConfigurations.epita = withSystem "x86_64-linux" (
    { pkgs, ... }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ({ ... }: {
          imports = [
            self.modules.homeManager.profileLightweight
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
