{ config
, lib
, pkgs
, ...
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
    - `kitty` program: default terminal
    - `nautilus` program: default file explorer
  '';

  config = lib.mkIf cfg.enable {
    assertions = [
      { assertion = config.programs.firefox.enable; message = "`xdg-mime` fragment depends on `firefox` program"; }
      { assertion = config.programs.imv.enable; message = "`xdg-mime` fragment depends on `imv` program"; }
      { assertion = config.programs.kitty.enable; message = "`xdg-mime` fragment depends on `kitty` program"; }
      { assertion = lib.lists.count (drv: (drv.pname or "") == pkgs.nautilus.pname) config.home.packages > 0; message = "`xdg-mime` fragment depends on `nautilus` program"; }
    ];

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
