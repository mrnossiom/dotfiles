{ self
, config
, lib
, pkgs
, ...
}:

let
  inherit (self.inputs) zen-browser;

  policies = {
    DisableTelemetry = true;
    DisableFirefoxStudies = true;
    DontCheckDefaultBrowser = true;
    DisablePocket = true;
    SearchBar = "unified";
  };

  settings = {
    # Privacy and default bloat
    "extensions.pocket.enabled" = false;
    "browser.newtabpage.pinned" = "";
    "browser.topsites.contile.enabled" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.system.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

    # Reopen previous session
    "browser.startup.page" = true;

    # Use vertical tabs
    "sidebar.revamp" = true;
    "sidebar.verticalTabs" = true;

    # Disable swipe gesture
    "browser.gesture.swipe.left" = "";
    "browser.gesture.swipe.right" = "";

    "browser.search.defaultenginename" = "DuckDuckGo";
    "browser.search.order.1" = "DuckDuckGo";

    "signon.rememberSignons" = false;
    "widget.use-xdg-desktop-portal.file-picker" = 1;
    "browser.aboutConfig.showWarning" = false;

    # Enable meta devtools to inspect Firefox Chrome UI
    "devtools.chrome.enabled" = true;
    "devtools.debugger.remote-enabled" = true;

    # Pickup userChrome styles at startup
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

    # Firefox 75+ remembers the last workspace it was opened on as part of its session management.
    # This is annoying, because I can have a blank workspace, click Firefox from the launcher, and
    # then have Firefox open on some other workspace.
    "widget.disable-workspace-management" = true;
  };

  userContent = ''
    /* Darken PDFs in viewer to match system color scheme */
    @media (prefers-color-scheme: dark) {
      #viewerContainer > #viewer > .page > .canvasWrapper > canvas,
      #viewerContainer > #viewer > div.spread > .page > .canvasWrapper > canvas {
          filter: grayscale(1) invert(1) sepia(1);
      }
    }
  '';

  cfg = config.local.fragment.firefox;
in
{
  options.local.fragment.firefox.enable = lib.mkEnableOption ''
    Firefox related
  '';

  imports = [
    zen-browser.homeModules.beta
  ];

  config = lib.mkIf cfg.enable {
    home.sessionVariables.BROWSER = lib.getExe config.programs.zen-browser.package;

    stylix.targets.firefox = {
      enable = false;
      profileNames = [ "default" ];
    };
    stylix.targets.zen-browser = {
      enable = false;
      profileNames = [ "default" ];
    };

    programs.zen-browser = {
      enable = true;

      inherit policies;

      profiles.default = {
        isDefault = true;

        inherit
          settings
          userContent;
      };
    };

    programs.firefox = {
      enable = true;

      inherit policies;

      profiles.default = {
        isDefault = true;

        settings = settings // {
          "zen.view.experimental-no-window-controls" = true;
          "zen.view.show-newtab-button-top" = false;

          "zen.welcome-screen.seen" = true;
          "zen.workspaces.continue-where-left-off" = true;
          "zen.view.compact.enable-at-startup" = true;
          "zen.view.window.scheme" = 2; # 0 dark theme, 1 light theme, 2 auto

          # Remove borders around windows
          "zen.theme.content-element-separation" = 0;
        };

        inherit userContent;

        # <https://www.userchrome.org/how-create-userchrome-css.html>
        userChrome = ''
          /* Hide close button */
          .titlebar-close { display: none !important; }
        '';

        search = {
          force = true;
          default = "ddg";
          order = [ "ddg" "wikipedia" "google" ];
        };
      };
    };
  };
}
