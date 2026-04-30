{
  symlinkJoin,
  writeTextDir,
}:

let
  # TODO: use globals.nix
  webfinger = writeTextDir ".well-known/webfinger" ''
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

  discord-proof = writeTextDir ".well-known/discord" ''
    dh=919234284ceb2aba439d15b9136073eb2308989b
  '';

  matrix-server-config = writeTextDir ".well-known/matrix/server" ''
    {"m.server":"matrix.wiro.world:443"}
  '';
  matrix-client-config = writeTextDir ".well-known/matrix/client" ''
    {"m.homeserver":{"base_url":"https://matrix.wiro.world/"}}
  '';
in
symlinkJoin {
  name = "additional-website-files";
  paths = [
    webfinger
    discord-proof
    matrix-server-config
    matrix-client-config
  ];
}
