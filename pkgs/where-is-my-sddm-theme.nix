{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "where-is-my-sddm-theme";
  version = "v1.12.0";

  src = fetchFromGitHub {
    owner = "stepanzubkov";
    repo = "where-is-my-sddm-theme";
    rev = version;
    hash = "sha256-+R0PX84SL2qH8rZMfk3tqkhGWPR6DpY1LgX9bifNYCg=";
  };

  dontBuild = true;
  installPhase = ''
    mkdir -p $out/share/sddm/themes
    cp -aR $src/where_is_my_sddm_theme/ $out/share/sddm/themes/
  '';
}  
