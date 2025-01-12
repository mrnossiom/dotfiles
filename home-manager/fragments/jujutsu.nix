{ config
, lib
, pkgs
, lpkgs
, ...
}:

let
  flags = config.local.flags;

  cfg = config.local.fragment.jujutsu;
in
{
  options.local.fragment.jujutsu.enable = lib.mkEnableOption ''
    Jujutsu related
  '';

  config = lib.mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;
      package = if flags.onlyCached then pkgs.jujutsu else lpkgs.jujutsu;

      settings = {
        user = {
          name = "Milo Moisson";
          email = "milomoisson@gmail.com";
        };

        signing = {
          backend = "gpg";
          key = "3C01CA5E";

          git.sign-on-push = true;
        };

        ui = {
          default-command = "log";

          diff-editor = ":builtin";
          merge-editor = ":builtin";

          diff.tool = [ "difft" "--color=always" "--display=inline" "$left" "$right" ];
        };

        aliases = {
          ui = [ "util" "exec" "--" "lazyjj" ];
        };
      };
    };

    home.packages = with pkgs; [
      difftastic
      lazyjj
    ];
  };
}
