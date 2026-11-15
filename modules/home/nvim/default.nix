# Neovim, configured with nixvim. The editor config itself is in nixvim.nix.
{ flake, ... }:
{
  imports = [ flake.inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true; # EDITOR=nvim
    imports = [ ./nixvim.nix ];
  };
}
