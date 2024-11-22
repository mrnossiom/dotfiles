final: prev:

with final.lib;

{
  # TODO: remove once github:swaywm/swaylock#369 is merged
  swaylock = prev.swaylock.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "mrnossiom";
      repo = "swaylock";
      rev = "5aebb558663bebb09b86d6c4ca9b760791507b88";
      hash = "sha256-1XotT0XKoDyg7ytzoqgxdHHA64oce4b8CZU53luI5j0=";
    };
  });
}
