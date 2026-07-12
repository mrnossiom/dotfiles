{
  config,
  lib,
  ...
}:

let
  cfg = config.local.fragment.thunderbird;
in
{
  options.local.fragment.thunderbird.enable = lib.mkEnableOption ''
    Thunderbird related
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

          # https://superuser.com/questions/13518/change-the-default-sorting-order-in-thunderbird
          # order descending is 2, type id is 22
          "mailnews.default_news_sort_order" = 2;
          "mailnews.default_news_sort_type" = 22;
          "mailnews.default_sort_order" = 2;
          "mailnews.default_sort_type" = 22;

          # Use compact cards
          "mail.threadpane.listview" = 0;
          "mail.threadpane.cardsview.rowcount" = 2; # 2 row instead of 1

          # Start weeks on Monday
          "calendar.week.start" = 1;
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
