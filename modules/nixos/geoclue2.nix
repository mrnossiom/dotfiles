# Adapted from the original nixpkgs repo
#
# It supports static location fallback. This is a workaround waiting for an
# alternative to MLS (Mozilla Location Services).

# Target interface to manage the static file would be:
# static = {
#   latitude = 48.8;
#   logitude = 2.3;
# };
#
# I spent way too much time getting this to work with a submodule.

{ config
, lib
, pkgs
, ...
}:

let
  package = pkgs.geoclue2.override { withDemoAgent = config.services.geoclue2.enableDemoAgent; };

  cfg = config.services.geoclue2;

  defaultWhitelist = [ "gnome-shell" "io.elementary.desktop.agent-geoclue2" ];

  appConfigModule = lib.types.submodule ({ name, ... }: with lib; {
    options = {
      desktopID = mkOption {
        type = types.str;
        description = "Desktop ID of the application.";
      };

      isAllowed = mkOption {
        type = types.bool;
        description = ''
          Whether the application will be allowed access to location information.
        '';
      };

      isSystem = mkOption {
        type = types.bool;
        description = ''
          Whether the application is a system component or not.
        '';
      };

      users = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          List of UIDs of all users for which this application is allowed location
          info access, Defaults to an empty string to allow it for all users.
        '';
      };
    };

    config.desktopID = mkDefault name;
  });

  # staticModule = types.submodule ({ name, ... }: {
  #   options = {
  #     latitude = mkOption {
  #       type = types.float;
  #       example = 40.6893129;
  #     };

  #     longitude = mkOption {
  #       type = types.float;
  #       example = -74.0445531;
  #     };

  #     altitude = mkOption {
  #       type = types.float;
  #       default = 0;
  #       example = 96;
  #     };

  #     accuracyRadius = mkOption {
  #       type = types.float;
  #       default = 0;
  #       example = 1.83;
  #     };
  #   };
  # });

  appConfigToINICompatible = _: { desktopID, isAllowed, isSystem, users, ... }: {
    name = desktopID;
    value = {
      allowed = isAllowed;
      system = isSystem;
      users = lib.concatStringsSep ";" users;
    };
  };

in
{
  disabledModules = [ "services/desktops/geoclue2.nix" ];

  options.services.geoclue2 = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable GeoClue 2 daemon, a DBus service
        that provides location information for accessing.
      '';
    };

    enableDemoAgent = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to use the GeoClue demo agent. This should be
        overridden by desktop environments that provide their own
        agent.
      '';
    };

    enableNmea = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to fetch location from NMEA sources on local network.
      '';
    };

    enable3G = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable 3G source.
      '';
    };

    enableCDMA = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable CDMA source.
      '';
    };

    enableModemGPS = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable Modem-GPS source.
      '';
    };

    enableWifi = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable WiFi source.
      '';
    };

    geoProviderUrl = mkOption {
      type = types.str;
      default = "https://location.services.mozilla.com/v1/geolocate?key=geoclue";
      example = "https://www.googleapis.com/geolocation/v1/geolocate?key=YOUR_KEY";
      description = ''
        The url to the wifi GeoLocation Service.
      '';
    };

    submitData = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to submit data to a GeoLocation Service.
      '';
    };

    submissionUrl = mkOption {
      type = types.str;
      default = "https://location.services.mozilla.com/v1/submit?key=geoclue";
      description = ''
        The url to submit data to a GeoLocation Service.
      '';
    };

    submissionNick = mkOption {
      type = types.str;
      default = "geoclue";
      description = ''
        A nickname to submit network data with.
        Must be 2-32 characters long.
      '';
    };

    appConfig = mkOption {
      type = types.attrsOf appConfigModule;
      default = { };
      example = {
        "com.github.app" = {
          isAllowed = true;
          isSystem = true;
          users = [ "300" ];
        };
      };
      description = ''
        Specify extra settings per application.
      '';
    };

    # static = mkOption {
    #   type = types.nullOr (types.attrsOf staticModule);
    #   default = null;
    #   description = ''
    #     Add a fallback location that will be overriden by other location services
    #   '';
    # };

    staticFile = mkOption {
      type = types.nullOr (types.str);
      default = null;
      description = ''
        Add a fallback location that will be overriden by other location services
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ package ];

    services.dbus.packages = [ package ];

    systemd.packages = [ package ];

    # we cannot use DynamicUser as we need the the geoclue user to exist for the
    # dbus policy to work
    users = {
      users.geoclue = {
        isSystemUser = true;
        home = "/var/lib/geoclue";
        group = "geoclue";
        description = "Geoinformation service";
      };

      groups.geoclue = { };
    };

    systemd.services.geoclue = {
      wants = lib.optionals cfg.enableWifi [ "network-online.target" ];
      after = lib.optionals cfg.enableWifi [ "network-online.target" ];
      # restart geoclue service when the configuration changes
      restartTriggers = [
        config.environment.etc."geoclue/geoclue.conf".source
      ];
      serviceConfig.StateDirectory = "geoclue";
    };

    # this needs to run as a user service, since it's associated with the
    # user who is making the requests
    systemd.user.services = lib.mkIf cfg.enableDemoAgent {
      geoclue-agent = {
        description = "Geoclue agent";
        # this should really be `partOf = [ "geoclue.service" ]`, but
        # we can't be part of a system service, and the agent should
        # be okay with the main service coming and going
        wantedBy = [ "default.target" ];
        wants = lib.optionals cfg.enableWifi [ "network-online.target" ];
        after = lib.optionals cfg.enableWifi [ "network-online.target" ];
        unitConfig.ConditionUser = "!@system";
        serviceConfig = {
          Type = "exec";
          ExecStart = "${package}/libexec/geoclue-2.0/demos/agent";
          Restart = "on-failure";
          PrivateTmp = true;
        };
      };
    };

    services.geoclue2.appConfig = {
      epiphany = { isAllowed = true; isSystem = false; };
      firefox = { isAllowed = true; isSystem = false; };
    };

    environment.etc."geoclue/geoclue.conf".text =
      lib.generators.toINI { } ({
        agent = {
          whitelist = lib.concatStringsSep ";"
            (lib.optional cfg.enableDemoAgent "geoclue-demo-agent" ++ defaultWhitelist);
        };
        network-nmea = {
          enable = cfg.enableNmea;
        };
        "3g" = {
          enable = cfg.enable3G;
        };
        cdma = {
          enable = cfg.enableCDMA;
        };
        modem-gps = {
          enable = cfg.enableModemGPS;
        };
        wifi = {
          enable = cfg.enableWifi;
          url = cfg.geoProviderUrl;
          submit-data = lib.boolToString cfg.submitData;
          submission-url = cfg.submissionUrl;
          submission-nick = cfg.submissionNick;
        };
      } // lib.mapAttrs' appConfigToINICompatible cfg.appConfig);

    # environment.etc."geolocation" = mkIf (cfg.static != null) {
    #   text = ''
    #     ${toString cfg.static.latitude}
    #     ${toString cfg.static.longitude}
    #     ${toString cfg.static.altitude}
    #     ${toString cfg.static.accuracyRadius}
    #   '';
    # };

    environment.etc."geolocation" = lib.mkIf (cfg.staticFile != null) { text = cfg.staticFile; };
  };

  meta = with lib; {
    maintainers = with maintainers; [ ] ++ teams.pantheon.members;
  };
}
