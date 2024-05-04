{ lib
, stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  pname = "probe-rs-udev-rules";
  version = "0.0.0";

  src = fetchurl {
    url = "https://probe.rs/files/69-probe-rs.rules";
    hash = "sha256-SdwESnOuvOKMsTvxyA5c4UwtcS3kU33SlNttepMm7HY=";
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm 644 "${src}" "$out/lib/udev/rules.d/69-probe-rs.rules"
  '';

  meta = with lib; {
    description = "UDev rules for Probe-rs supported probes calculators";
    homepage = "https://probe.rs/";
    maintainers = [ "mrnossiom" ];
    platforms = platforms.linux;
  };
}
