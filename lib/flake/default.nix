pkgs:

{
  system = hostName: profile: {
    imports = [ profile ];
    networking.hostName = hostName;
  };

  user = import ./user.nix;
  managedDiskLayout = import ./managedDiskLayout.nix;
}
