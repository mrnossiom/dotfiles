final: prev:
with final.lib;
{
  # Geogebra locales clashes with Authy locales (why? I don't care)
  geogebra6 = prev.geogebra6.overrideAttrs (previousAttrs: {
    installPhase = previousAttrs.installPhase + ''rm -rf "$out/locales/"'';
  });

  # Darkman needs `bash` in path to execute scripts
  darkman = prev.darkman.overrideAttrs (prevAttrs:
    assert assertMsg (prevAttrs.version == "1.5.4")
      "FIXME: oblolete fix, darkman v${prevAttrs.version} shouldn't use bash to invoke scripts anymore";
    {
      nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ final.makeWrapper ];
      postFixup = "wrapProgram $out/bin/darkman --suffix PATH : ${makeBinPath (with final; [ bash ])}";
    }
  );
}
