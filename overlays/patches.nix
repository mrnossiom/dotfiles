final: prev: {
  # Geogebra locales clashes with Authy locales (why? I don't care)
  geogebra6 = prev.geogebra6.overrideAttrs (previousAttrs: {
    installPhase = previousAttrs.installPhase + ''rm -rf "$out/locales/"'';
  });

  # Darkman needs bash in path to execute scripts
  # Will be fixed in the next release
  darkman = prev.darkman.overrideAttrs (prevAttrs: {
    nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ final.makeWrapper ];
    postFixup = "wrapProgram $out/bin/darkman --suffix PATH : ${final.lib.makeBinPath (with final; [ bash ])}";
  });
}
