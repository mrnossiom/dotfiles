{ appimageTools
, fetchurl
 }:

let
  pname = "cura";
  version = "5.9.0";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://github.com/Ultimaker/Cura/releases/download/${version}/UltiMaker-Cura-${version}-linux-X64.AppImage";
    hash = "sha256-STtVeM4Zs+PVSRO3cI0LxnjRDhOxSlttZF+2RIXnAp4=";
  };
  
  contents = appimageTools.extractType2 { inherit name src; };
in

appimageTools.wrapType2 rec {
  inherit name src;

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}

    install -m 444 -D ${contents}/com.ultimaker.cura.desktop -t $out/share/applications

    substituteInPlace $out/share/applications/com.ultimaker.cura.desktop \
      --replace-fail 'Exec=UltiMaker-Cura' 'Exec=${pname}'

    cp -r ${contents}/usr/share/icons $out/share
  '';
}
