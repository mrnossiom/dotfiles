rec {
  # Machine SSH key (/etc/ssh/ssh_host_ed25519_key.pub)
  archaic = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDuBHC0f7N0q1KRczJMoaBVdY0JFOtcpPy6WlYsoxUh";
  neo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINR1/9o1HLnSRkXt3xxAM5So1YCCNdJpBN1leSu7giuR";
  systems = [ archaic neo ];

  # weird-row = "...";
  servers = [
    # weird-row
  ];

  # Sessions specific age key (~/.ssh/id_home_manager.pub)
  neo-milomoisson = "age1vz2zmduaqhaw5jrqh277pmp36plyth8rz5k9ccxeftfcl2nlhalqwvx5xz";
  sessions = [ neo-milomoisson ];

  # User keys (~/.ssh/id_ed25519.pub)
  milomoisson = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJdt7atyPTOfaBIsgDYYb0DG1yid2u78abaCDji6Uxgi";
  wirody = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMdW6ijH9oTsrswUJmQBF2LQkhjrMFkJ1LktnirPuL2S";
  users = [ milomoisson wirody ];
}
