# This flake library is available to modules via the `llib` arg
{
  self,
  ...
}:

let
  inherit (self.inputs) net;
in
{
  net = net.lib;
}
