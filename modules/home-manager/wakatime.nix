{ config
, lib
, pkgs
, ...
}:

with lib;

let
  cfg = config.programs.wakatime;

  configFormat = pkgs.formats.ini { };
in
{
  options.programs.wakatime = {
    enable = mkEnableOption "Wakatime code time tracker";

    apiKeyFile = mkOption {
      description = "Path to a file containing your api key";
      type = types.nullOr types.str;
    };

    settings = mkOption {
      description = "Wakatime CLI settings that impacts every extension";
      default = { };
      example = {
        exclude = [
          "^COMMIT_EDITMSG$"
          "^TAG_EDITMSG$"
          "^/var/(?!www/).*"
          "^/etc/"
        ];
        include = [ ".*" ];
      };
      type = configFormat.type;
    };

    extraConfig = mkOption {
      description = "Define additional wakatime configuration options";
      default = { };
      example = {
        git = {
          submodules_disabled = false;
          project_from_git_remote = false;
        };
      };
      type = configFormat.type;
    };
  };

  config =
    let
      merged-settings = cfg.settings // { settings.api_key_vault_cmd = pkgs.writeShellScript "cat-wakatime-api-key" "cat ${cfg.apiKeyFile}"; };
      merged-config = cfg.extraConfig // merged-settings;
    in
    mkIf cfg.enable {
      home.sessionVariables.WAKATIME_HOME = "${config.xdg.configHome}/wakatime";

      xdg.configFile = {
        "wakatime/.wakatime.cfg".source = configFormat.generate "wakatime-config" merged-config;
      };
    };
}

