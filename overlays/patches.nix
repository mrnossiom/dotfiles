final: prev:
with final.lib;
{
  # Darkman needs `bash` in path to execute scripts
  darkman = prev.darkman.overrideAttrs (prevAttrs:
    assert assertMsg (prevAttrs.version == "1.5.4")
      "FIXME: oblolete fix, darkman v${prevAttrs.version} shouldn't use bash to invoke scripts anymore";
    {
      nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ final.makeWrapper ];
      postFixup = "wrapProgram $out/bin/darkman --suffix PATH : ${makeBinPath (with final; [ bash ])}";
    }
  );

  figma-linux = prev.figma-linux.overrideAttrs (prevAttrs: {
    buildInputs = prevAttrs.buildInputs ++ [ prev.makeWrapper ];
    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib && cp -r opt/figma-linux/* $_
      mkdir -p $out/bin && ln -s $out/lib/figma-linux $_/figma-linux

      cp -r usr/* $out

      wrapProgramShell $out/bin/figma-linux \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--enable-features=UseOzonePlatform --ozone-platform=wayland}}"

      runHook postInstall
    '';
  });
}
