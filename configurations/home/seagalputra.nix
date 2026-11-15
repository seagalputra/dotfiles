# The user, on any OS. Machines with nix-darwin or NixOS include it for their primary
# user; elsewhere it is activated on its own with `nix run .#activate seagalputra@`.
{ flake, ... }:
{
  imports = [ flake.self.homeModules.default ];

  home.username = "seagalputra";

  # Used for backwards compatibility; read the release notes before changing.
  home.stateVersion = "26.11";
}
