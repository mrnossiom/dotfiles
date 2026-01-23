rec {
  # Machine SSH key (/etc/ssh/ssh_host_ed25519_key.pub)
  archaic-wiro-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDuBHC0f7N0q1KRczJMoaBVdY0JFOtcpPy6WlYsoxUh";
  neo-wiro-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINR1/9o1HLnSRkXt3xxAM5So1YCCNdJpBN1leSu7giuR";
  systems = [
    archaic-wiro-laptop
    neo-wiro-laptop
  ];

  weird-row-server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII5sThvKuIj8yfeZzUPYfxWxnjTTdNtSID2OL4czE8AL";
  servers = [ weird-row-server ];

  # Sessions specific age key (~/.ssh/id_home_manager.pub)
  neo-milo = "age1vz2zmduaqhaw5jrqh277pmp36plyth8rz5k9ccxeftfcl2nlhalqwvx5xz";
  sessions = [ neo-milo ];

  # User keys (~/.ssh/id_{ed25519,ecdsa}.pub)
  milo-ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJdt7atyPTOfaBIsgDYYb0DG1yid2u78abaCDji6Uxgi";
  wirody = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMdW6ijH9oTsrswUJmQBF2LQkhjrMFkJ1LktnirPuL2S";
  users = [
    milo-ed25519
    wirody
  ];
}
