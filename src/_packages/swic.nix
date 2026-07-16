{
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "swic";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "jvoisin";
    repo = pname;
    rev = "f9fb77a3c212c0bfdc0ebe1d817f8f0946d964b2";
    sha256 = "sha256-gh8A2Vlg1FiKgPnnwNZva8FOYTs9LJGJpQq8wHlcj6Q=";
  };

  vendorHash = "sha256-Iebe5Kd67jR7W/VLn86PzKCQFj+0UC59u7LILktWYj8=";
}
