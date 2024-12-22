{ appimageTools
, fetchurl
 }:

appimageTools.wrapType2 rec {
  pname = "cura";
  version = "5.9.0";

  src = fetchurl {
    url = "https://github.com/Ultimaker/Cura/releases/download/${version}/UltiMaker-Cura-${version}-linux-X64.AppImage";
    hash = "sha256-STtVeM4Zs+PVSRO3cI0LxnjRDhOxSlttZF+2RIXnAp4=";
  };
}
