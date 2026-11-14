{
  description = "macOS setup: nix-darwin + home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nix-darwin,
      home-manager,
      rust-overlay,
      ...
    }:
    let
      user = "seagalputra";
    in
    {
      # `darwin-rebuild switch --flake .` picks the entry named after `scutil --get LocalHostName`.
      darwinConfigurations."Seagals-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit self user; };
        modules = [
          ./nix/darwin.nix
          { nixpkgs.overlays = [ rust-overlay.overlays.default ]; }
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Files that are in the way (old Stow links, ~/.config/nvim) are moved aside, not overwritten.
            home-manager.backupFileExtension = "before-nix";
            home-manager.users.${user} = ./nix/home.nix;
          }
        ];
      };
    };
}
