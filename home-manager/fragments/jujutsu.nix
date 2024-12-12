{ config
, lib
, pkgs
, upkgs
, ...
}:

let
  cfg = config.local.fragment.jujutsu;
in
{
  options.local.fragment.jujutsu.enable = lib.mkEnableOption ''
    Jujutsu related
  '';

  config = lib.mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;
      package = upkgs.jujutsu;
      
      settings = {
        user = {
          name = "Milo Moisson";
          email = "milomoisson@gmail.com";
        };

        signing = {
          sign-all = true;
          backend = "gpg";
          key = "3C01CA5E";

          backends.gpg.allow-expired-keys = false;
        };

        ui = {
          default-command = "log";

          diff-editor = ":builtin";

          diff.tool = [ "difft" "--color=always" "--display=inline" "$left" "$right" ];
        };

        aliases = {
          ui = ["util" "exec" "--" "lazyjj"];
        };
      };
    };

    home.packages = with pkgs; [
      difftastic
      lazyjj
    ];
  };
}
