{
  swaylock,
  fetchFromGitHub,
  ...
}:

# TODO: remove once github:swaywm/swaylock#369 is merged
swaylock.overrideAttrs (old: {
  src = fetchFromGitHub {
    owner = "mrnossiom";
    repo = "swaylock";
    rev = "164e46e1b632872ef62dd414c634f3983cb6ac56";
    hash = "sha256-9yEfcU3lc2ZXqf4XTVLmYQqdNpsR3WtuWjqyeBf2yx4=";
  };
})
