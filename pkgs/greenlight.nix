{ dpkg
, fetchurl
, lib
, stdenv
  # Libraries
, glib
, nss
, nspr
, at-spi2-atk
, cups
, dbus
, libdrm
, gtk3
, pango
, cairo
, xorg
, mesa
, expat
, libxkbcommon
, alsa-lib
, libglvnd
}:

let
  rpath = lib.makeLibraryPath [
    glib
    nss
    nspr
    at-spi2-atk
    cups
    dbus
    libdrm
    gtk3
    pango
    cairo
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    mesa
    expat
    xorg.libxcb
    libxkbcommon
    alsa-lib

    libglvnd
  ];
in
stdenv.mkDerivation
rec {
  pname = "greenlight";
  version = "2.0.1";

  src = fetchurl {
    url = "https://github.com/unknownskl/greenlight/releases/download/v${version}/greenlight_${version}_amd64.deb";
    hash = "sha256-Qr5CVAzfIssXvWchy573KpIiHH6UbC9kJ+4yfAreF+o=";
  };

  nativeBuildInputs = [ dpkg ];

  unpackPhase = ''
    mkdir -p $out
    dpkg-deb -x $src $out
    cp -av $out/usr/* $out
    cp -av $out/opt/Greenlight $out/share/greenlight
    rm -rf $out/opt $out/usr

    mkdir -p $out/bin
    ln -s "$out/share/greenlight/greenlight" "$out/bin/greenlight"

    # Otherwise it looks "suspicious"
    chmod -R g-w $out
  '';

  postFixup = ''
    for file in $(find $out -type f \( -perm /0111 -o -name \*.so\* -or -name \*.node\* \) ); do
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" || true
      patchelf --set-rpath ${rpath}:$out/share/greenlight $file || true
    done

    # Fix the desktop link
    substituteInPlace $out/share/applications/greenlight.desktop \
      --replace /usr/bin/ ""
  '';

  meta = with lib; {
    homepage = "https://github.com/unknownskl/greenlight";
    description = "";
    platforms = [ "x86_64-linux" ];
    license = licenses.mit;
    maintainers = with maintainers; [ mrnossiom ];
  };
}
