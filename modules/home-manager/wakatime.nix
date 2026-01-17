{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.programs.wakatime;

  ini-format = pkgs.formats.ini { };
in
{
  options.programs.wakatime = with lib; {
    enable = mkEnableOption "Wakatime code time tracker";

    apiKeyFile = mkOption {
      description = "Path to a file containing your api key";
      type = types.nullOr types.str;
    };

    settings = mkOption {
      description = ''
        Wakatime CLI settings that impacts every extension

        See options at <https://github.com/wakatime/wakatime-cli/blob/develop/USAGE.md#ini-config-file>
      '';
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
      # We only want a single INI section type
      type = ini-format.type.nestedTypes.elemType;
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
      type = ini-format.type;
    };
  };

  config =
    let
      # Bash script is needed cause file path can contain env variables
      # e.g. agenix uses `$XDG_RUNTIME_DIR`
      wakatime-key = pkgs.writeShellScript "cat-wakatime-api-key" "cat ${cfg.apiKeyFile}";

      merged-settings = cfg.settings // { api_key_vault_cmd = "${wakatime-key}"; };
      final-config = cfg.extraConfig // { settings = merged-settings; };
    in
    lib.mkIf cfg.enable {
      home.sessionVariables.WAKATIME_HOME = "${config.xdg.configHome}/wakatime";

      xdg.configFile."wakatime/.wakatime.cfg".source = ini-format.generate "wakatime-config" final-config;
    };
}

