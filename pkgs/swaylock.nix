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
    rev = "c1f213e8ba96706e9f42963941850ffb51bd9e53";
    hash = "sha256-1OeReYEJv66fHUiHL0B1+H0aQNqWlY2ZauFVyAAMNTo=";
  };
})
