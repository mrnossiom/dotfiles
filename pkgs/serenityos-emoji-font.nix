{ lib
, stdenv
, fetchurl
, ...
}:

stdenv.mkDerivation {
  pname = "serenityos-emoji-font";
  version = "0.0.0";

  src = fetchurl {
    url = "https://linusg.github.io/serenityos-emoji-font/SerenityOS-Emoji.ttf";
    hash = "sha256-j3icyvz8BVI1i8erLj80yuoilxdhodQvBMaTwxs9Xm4=";
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm644 $src $out/share/fonts/truetype/SerenityOS-Emoji.ttf
  '';

  meta = with lib; {
    description = "SerenityOS🐞 emoji set is a fantastic pixel art🎨 set built for SerenityOS but now available for everyone, each glyph is at most 10x10px🔍";
    homepage = "https://emoji.serenityos.org/";
    license = licenses.bsd2;
    maintainers = with maintainers; [ "mrnossiom" ];
  };
}
