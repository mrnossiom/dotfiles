{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.fragment.firefox;
in
{
  options.local.fragment.firefox.enable = lib.mkEnableOption ''
    Firefox related
  '';

  config = lib.mkIf cfg.enable {
    home.sessionVariables.BROWSER = lib.getExe pkgs.firefox;

    stylix.targets.firefox.profileNames = [ "default" ];

    programs.firefox = {
      enable = true;

      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DontCheckDefaultBrowser = true;
        DisablePocket = true;
        SearchBar = "unified";
      };

      profiles.default = {
        isDefault = true;

        settings = {
          # Privacy and default bloat
          "extensions.pocket.enabled" = false;
          "browser.newtabpage.pinned" = "";
          "browser.topsites.contile.enabled" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.system.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

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

        # <https://www.userchrome.org/how-create-userchrome-css.html>
        userChrome = ''
          /* Hide close button */
          .titlebar-close { display: none !important; }
        '';

        userContent = ''
          /* Darken PDFs in viewer to match system color scheme */
          @media (prefers-color-scheme: dark) {
            #viewerContainer > #viewer > .page > .canvasWrapper > canvas,
            #viewerContainer > #viewer > div.spread > .page > .canvasWrapper > canvas {
                filter: grayscale(1) invert(1) sepia(1);
            }
          }
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
