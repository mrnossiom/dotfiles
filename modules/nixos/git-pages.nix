{
  config,
  lib,
  pkgs,
  lpkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    mkIf
    types
    ;

  cfg = config.services.git-pages;

  toml-format = pkgs.formats.toml { };
  configFile = toml-format.generate "git-pages-config.toml" cfg.settings;
in
{
  options.services.git-pages = {
    enable = mkEnableOption "git-pages static site server";

    package = mkPackageOption lpkgs "git-pages" { };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/git-pages";
      description = "Directory to store site data and manifests.";
    };

    insecure = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable PAGES_INSECURE (disables authentication). Do not use in production.";
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      example = {
        storage = {
          type = "filesystem";
          path = "/var/lib/git-pages/data";
        };
      };
      description = "Structured TOML configuration for the server.";
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "File containing environment variables (e.g., for S3 credentials or Sentry DSN).";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.git-pages = {
      description = "git-pages static site server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/git-pages -config ${configFile}";
        Restart = "always";
        User = "git-pages";
        Group = "git-pages";
        StateDirectory = "git-pages";
        WorkingDirectory = cfg.dataDir;
        EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;
      };

      environment = {
        PAGES_INSECURE = if cfg.insecure then "1" else "0";
        ENVIRONMENT = "production";
      };
    };

    users.users.git-pages = {
      isSystemUser = true;
      group = "git-pages";
      home = cfg.dataDir;
      createHome = true;
    };
    users.groups.git-pages = { };
  };
}
