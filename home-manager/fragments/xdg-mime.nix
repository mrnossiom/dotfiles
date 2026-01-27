{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.fragment.xdg-mime;
in
{
  options.local.fragment.xdg-mime.enable = lib.mkEnableOption ''
    Sets default applications based on mime type.

    Depends on:
    - `firefox` program: default browser
    - `imv` program: default image viewer
    - `nautilus` program: default file explorer
  '';

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.programs.firefox.enable;
        message = "`xdg-mime` fragment depends on `firefox` program";
      }
      {
        assertion = config.programs.imv.enable;
        message = "`xdg-mime` fragment depends on `imv` program";
      }
      {
        assertion =
          lib.lists.count (drv: (drv.pname or "") == pkgs.nautilus.pname) config.home.packages > 0;
        message = "`xdg-mime` fragment depends on `nautilus` program";
      }
    ];

    xdg.enable = true;

    xdg.mimeApps = {
      enable = true;

      defaultApplications =
        let
          files = [ "org.gnome.Nautilus.desktop" ];
          browser = [ "zen-beta.desktop" ];
          images = [ "imv.desktop" ];
          video = [ "mpv.desktop" ];
          audio = [ "mpv.desktop" ];
          torrents = [ "transmission-gtk.desktop" ];
        in
        {
          "inode/directory" = files ++ images ++ audio ++ video;

          "application/pdf" = browser;
          "text/html" = browser;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/about" = browser;
          "x-scheme-handler/unknown" = browser;
          "image/svg+xml" = browser;

          "image/bmp" = images;
          "image/gif" = images;
          "image/jpeg" = images;
          "image/jpg" = images;
          "image/pjpeg" = images;
          "image/png" = images;
          "image/tiff" = images;
          "image/heif" = images;

          "video/mp4" = video;
          "video/x-matroska" = video;

          "audio/flac" = audio;

          "x-scheme-handler/magnet" = torrents;
          "application/x-bittorrent" = torrents;
        };

      associations.added = {
        "inode/directory" = [
          "imv.desktop"
          "mpv.desktop"
        ];

        "application/pdf" = [ "firefox.desktop" ];
        "x-scheme-handler/about" = [ "firefox.desktop" ];
        "x-scheme-handler/unknown" = [ "firefox.desktop" ];

        ## Correct LibreOffice applications
        "application/vnd.oasis.opendocument.text" = [ "writer.desktop" ];
        # Word : `.docx`
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ];
      };
      associations.removed = { };
    };

    # Force override file which is not symlinked for whatever reason and causes errors on rebuilds
    xdg.configFile."mimeapps.list".force = true;
  };
}
