{ lib
, config
, ...
}:

let
  cfg = config.local.fragment.thunderbird;
in
{
  options.local.fragment.thunderbird.enable = lib.mkEnableOption ''
    `imv` related
  '';

  config = lib.mkIf cfg.enable {
    programs.thunderbird = {
      enable = true;

      profiles.default = {
        isDefault = true;

        settings = {
          # Enable meta devtools to inspect Thunderbird Chrome UI
          "devtools.chrome.enabled" = true;
          "devtools.debugger.remote-enabled" = true;
        };

        # <https://www.userchrome.org/how-create-userchrome-css.html>
        userChrome = ''
          /* Hide close button */
          .titlebar-close { display: none !important; }
        '';
      };
    };
  };
}

