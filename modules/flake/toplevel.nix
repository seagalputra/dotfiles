# Flake-level glue: turns configurations/ and modules/ into flake outputs.
{ inputs, ... }:
{
  imports = [
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
  ];

  perSystem =
    { self', pkgs, ... }:
    {
      formatter = pkgs.nixfmt-tree; # `nix fmt`

      # `nix run` activates this machine: darwin-rebuild or nixos-rebuild, picked by hostname.
      packages.default = self'.packages.activate;
    };
}
