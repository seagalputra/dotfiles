# This Mac. The file name must match `hostname -s`.
{ flake, ... }:
{
  imports = [ flake.self.darwinModules.default ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.primaryUser = "seagalputra";

  # Used for backwards compatibility; read the changelog before changing.
  system.stateVersion = 7;
}
