{ lib
, pkgs
, ...
}:

with lib;

let
  lock = value: { Value = value; Status = "locked"; };
in

{
  config = {
    home.sessionVariables.BROWSER = getExe pkgs.firefox;

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

        search = {
          force = true;
          default = "DuckDuckGo";
          order = [ "DuckDuckGo" "Wikipedia" "Google" ];
        };
      };
    };
  };
}
