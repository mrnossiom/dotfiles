{
  flake.modules.homeManager.foot = { config, lib, ... }: {
    config = {
      home.sessionVariables.TERMINAL = lib.getExe config.programs.foot.package;

      programs.foot = {
        enable = true;

        # TODO: promising but too buggy
        # server.enable = true;
      };
    };
  };
}
