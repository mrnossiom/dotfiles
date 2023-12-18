{ dpkg, fetchurl, lib, stdenv }: stdenv.mkDerivation rec {
  pname = "greenlight";
  version = "2.0.0-beta15";

  src = fetchurl {
    url = "https://github.com/unknownskl/greenlight/releases/download/v${version}/greenlight_${version}_amd64.deb";
    hash = "sha256-0MYd3tsKwy/xtXULrPfwznKqBRiVqGfcMCJ+I0u8JJw=";
  };

  unpackPhase = "dpkg-deb -x $src $out";

  nativeBuildInputs = [ dpkg ];

  meta = with lib; {
    homepage = "https://github.com/unknownskl/greenlight";
    description = "";
    platforms = [ "x86_64-linux" ];
    license = licenses.mit;
    maintainers = with maintainers; [ mrnossiom ];
  };
}
