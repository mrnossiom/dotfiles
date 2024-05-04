{ lib
, stdenv
, writeText
}:

stdenv.mkDerivation rec {
  pname = "arduino-udev-rules";
  version = "0.0.0";

  src = writeText pname ''
    # Arduino Nano
    ATTRS{idVendor}=="2341", ATTRS{idProduct}=="8037", MODE="0666", TAG+="uaccess"
  '';

  dontUnpack = true;

  installPhase = ''
    install -Dm 644 "${src}" "$out/lib/udev/rules.d/70-arduino.rules"
  '';

  meta = with lib; {
    description = "UDev rules for Arduino boards";
    homepage = "https://www.arduino.cc/";
    maintainers = [ "mrnossiom" ];
    platforms = platforms.linux;
  };
}

