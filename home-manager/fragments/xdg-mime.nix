{ config
, lib
, ...
}:

let
  cfg = config.local.fragment.xdg-mime;
in
{
  # TODO: enforce dependence
  options.local.fragment.xdg-mime.enable = lib.mkEnableOption ''
    Sets default applications based on mime type.

    Depends on: `nautilus`, `firefox`, `imv`, `kitty`.
  '';

  config = lib.mkIf cfg.enable {
    xdg.mimeApps = {
      enable = true;

      defaultApplications =
        let
          files = [ "org.gnome.Nautilus.desktop" ];
          browser = [ "firefox.desktop" ];
          images = [ "imv.desktop" ];
          terminal = [ "kitty-open.desktop" ];
        in
        {
          "inode/directory" = files;

          "application/pdf" = browser;
          "text/html" = browser;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/about" = browser;
          "x-scheme-handler/unknown" = browser;
          "image/svg+xml" = browser;

          # Associate images to `imv`
          "image/bmp" = images;
          "image/gif" = images;
          "image/jpeg" = images;
          "image/jpg" = images;
          "image/pjpeg" = images;
          "image/png" = images;
          "image/tiff" = images;
          "image/heif" = images;

          "text/plain" = terminal;
          "text/markdown" = terminal;
          "text/javascript" = terminal;
          # this is how `.ts` files are matched
          "text/vnd.trolltech.linguist" = terminal;
          "text/x-java" = terminal;
        };

      associations.added = {
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
