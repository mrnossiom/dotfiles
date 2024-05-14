{ config
, lib
, pkgs
, ...
}:

with lib;

let
  cfg = config.services.wl-clip-persist;
in
{
  options.services.wl-clip-persist = {
    enable = mkEnableOption "";

    package = mkPackageOption pkgs "wl-clip-persist" { };

    clipboard = mkOption {
      description = "The clipboard type to operate on";
      default = "regular";
      type = types.enum [ "regular" "primary" "both" ];
    };

    display = mkOption {
      description = "The wayland display to operate on";
      default = null;
      type = types.nullOr types.str;
    };

    ignoreEventOnError = mkOption {
      description = "Only handle selection events where no error occurred";
      default = null;
      type = types.nullOr types.bool;
    };

    allMimeTypeRegex = mkOption {
      description = "Only handle selection events where all offered MIME types have a match for the regex";
      default = null;
      type = types.nullOr types.str;
    };

    interruptOldClipboardRequests = mkOption {
      description = "Interrupt trying to send the old clipboard to other programs when the clipboard has been updated";
      default = null;
      type = types.nullOr types.bool;
    };

    selectionSizeLimit = mkOption {
      description = "Only handle selection events whose total data size does not exceed the size limit";
      default = null;
      type = types.nullOr types.int;
    };

    readTimeout = mkOption {
      description = "Timeout for trying to get the current clipboard";
      default = 500;
      type = types.int;
    };

    ignoreEventOnTimeout = mkOption {
      description = "Only handle selection events where no timeout occurred";
      default = null;
      type = types.nullOr types.bool;
    };

    writeTimeout = mkOption {
      description = "Timeout for trying to send the current clipboard to other programs";
      default = 3000;
      type = types.int;
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.wl-clip-persist = {
      Unit = {
        Description = "wl-clip-persist system service";
        PartOf = [ "graphical-session.target" ];
        BindsTo = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${getExe cfg.package} ${cli.toGNUCommandLineShell {} {
          clipboard = cfg.clipboard;
          display = cfg.display;
          ignore-event-on-error = cfg.ignoreEventOnError;
          all-mime-type-regex = cfg.allMimeTypeRegex;
          interrupt-old-clipboard-requests = cfg.interruptOldClipboardRequests;
          selection-size-limit = cfg.selectionSizeLimit;
          read-timeout = cfg.readTimeout;
          ignore-event-on-timeout = cfg.ignoreEventOnTimeout;
          write-timeout = cfg.writeTimeout;
        }}";
        Restart = "on-failure";
        TimeoutStopSec = 15;
      };

      Install.WantedBy = mkDefault [ "graphical-session.target" ];
    };
  };
}
