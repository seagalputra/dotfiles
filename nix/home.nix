# User level: packages and dotfiles.
{ config, pkgs, ... }:
let
  dotfiles = "${config.home.homeDirectory}/Documents/sources/dotfiles";
  # Link to the file in this repo, not a copy in the Nix store, so edits apply without a rebuild.
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  home.stateVersion = "26.11";

  home.packages = with pkgs; [
    # Tools
    clang-tools # clang-format
    gh
    kubectl
    lazygit
    libimobiledevice
    mole-cleaner # `mo`
    neovim
    ripgrep
    shellcheck
    starship
    tmux
    xcodegen

    # Languages: global defaults. A project that needs another version gets a devShell.
    nodejs_24
    corepack_24 # pnpm and yarn, at the version in package.json "packageManager"
    bun
    deno
    python314
    ruby_4_0
    go_1_27
    beam.packages.erlang_29.erlang
    beam.packages.erlang_29.elixir_1_20
    (rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" ];
      targets = [
        "aarch64-apple-ios"
        "aarch64-apple-ios-sim"
        "x86_64-apple-ios"
        "wasm32-unknown-unknown"
      ];
    })
  ];

  # Loads a project's devShell on `cd` (via .envrc `use flake`). Hooked into zsh in ~/.zshrc.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.file.".zshrc".source = link "zsh/.zshrc";
  home.file.".tmux.conf".source = link "tmux/.tmux.conf";
  xdg.configFile."ghostty".source = link "ghostty/.config/ghostty";
  xdg.configFile."nvim".source = link "nvim/.config/nvim";
  xdg.configFile."starship.toml".source = link "starship/.config/starship.toml";
}
