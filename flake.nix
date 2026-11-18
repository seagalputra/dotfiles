{
  description = "Nix setup for macOS, NixOS and other Linux, wired with nixos-unified";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixos-unified.url = "github:srid/nixos-unified";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # No `follows`: nixvim is tested against its own nixpkgs revision.
    nixvim.url = "github:nix-community/nixvim";
  };

  # Outputs come from the directory layout (https://nixos-unified.org/guide/autowiring):
  #   configurations/{darwin,nixos,home}/<name>.nix -> one machine or user each
  #   modules/{darwin,nixos,home}/                  -> shared settings they import
  #   modules/flake/                                -> flake-level glue
  outputs =
    inputs:
    inputs.nixos-unified.lib.mkFlake {
      inherit inputs;
      root = ./.;
      # nixos-unified's default also has x86_64-darwin, which nixpkgs 26.11 dropped.
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
    };
}
