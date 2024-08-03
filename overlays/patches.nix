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

  # TODO: remove once github:swaywm/swaylock#369 is merged
  swaylock = prev.swaylock.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "mrnossiom";
      repo = "swaylock";
      rev = "0e09892e93b82f6de2fcf10a773d5fbf9de61d73";
      hash = "sha256-IzgrQv/oJEyvlVlZCm/2LOhpxR4KfSz7llSq3s9t/qM=";
    };
  });
}
