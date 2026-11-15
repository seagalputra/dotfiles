# Loads a project's devShell on `cd` (via .envrc `use flake`).
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
