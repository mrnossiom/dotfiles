{ writeShellApplication

, curl
}:

writeShellApplication {
  name = "pasters";
  runtimeInputs = [ curl ];
  text = ''
    curl --data-binary @- https://paste.rs/
  '';
}
