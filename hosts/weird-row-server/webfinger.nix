{
  pkgs,
  config,
  ...
}:

let
  webfinger-dir = pkgs.writeTextDir ".well-known/webfinger" ''
    {
      "subject": "acct:milo@wiro.world",
      "aliases": [
        "mailto:milo@wiro.world",
        "https://wiro.world/"
      ],
      "links": [
        {
          "rel": "http://wiro.world/rel/avatar",
          "href": "https://wiro.world/logo.jpg",
          "type": "image/jpeg"
        },
        {
          "rel": "http://webfinger.net/rel/profile-page",
          "href": "https://wiro.world/",
          "type": "text/html"
        },
        {
          "rel": "http://openid.net/specs/connect/1.0/issuer",
          "href": "https://auth.wiro.world"
        }
      ]
    }
  '';

  well-known-discord-dir = pkgs.writeTextDir ".well-known/discord" ''
    dh=919234284ceb2aba439d15b9136073eb2308989b
  '';

  website-hostname = "wiro.world";
in
{
  config = {
    services.caddy = {
      virtualHosts.${website-hostname}.extraConfig = ''
        @webfinger {
          path /.well-known/webfinger
          method GET HEAD
          query resource=acct:milo@wiro.world
          query resource=mailto:milo@wiro.world
          query resource=https://wiro.world
          query resource=https://wiro.world/
        }
        route @webfinger {
          header {
            Content-Type "application/jrd+json"
            Access-Control-Allow-Origin "*"
            X-Robots-Tag "noindex"
          }
          root ${webfinger-dir}
          file_server
        }
      ''
      + ''
        @discord {
          path /.well-known/discord
          method GET HEAD
        }
        route @discord {
          header {
            Access-Control-Allow-Origin "*"
            X-Robots-Tag "noindex"
          }
          root ${well-known-discord-dir}
          file_server
        }
      '';
    };
  };
}
