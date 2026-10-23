{ self, ... }:
{
  flake.modules.homeManager.screen = { ... }: {
    imports = [ self.homeModules.screen ];

    config = {
      programs.screen = {
        enable = true;

        screenrc = ''
          startup_message off

          defscrollback 10000
        '';
      };
    };
  };
}
