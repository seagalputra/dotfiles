# Languages: global defaults. A project that needs another version gets a devShell.
{
  flake,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  # Erlang/OTP 29 with Elixir 1.20. Also builds elixir-ls, so it matches the global Elixir.
  beam = pkgs.beam.packages.erlang_29.overrideScope (final: _: { elixir = final.elixir_1_20; });
  rust-bin = flake.inputs.rust-overlay.lib.mkRustBin { } pkgs;
in
{
  home.packages = with pkgs; [
    nodejs_24
    corepack_24 # pnpm and yarn, at the version in package.json "packageManager"
    bun
    deno
    python314
    ruby_4_0
    go_1_27
    beam.erlang
    beam.elixir
    (rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" ];
      targets = [
        "wasm32-unknown-unknown"
      ]
      ++ lib.optionals isDarwin [
        "aarch64-apple-ios"
        "aarch64-apple-ios-sim"
        "x86_64-apple-ios"
      ];
    })
  ];

  programs.nixvim.lsp.servers.elixirls.package = beam.elixir-ls;

  # Nix's node and ruby are read-only, so global installs go to the home dir.
  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "$HOME/.local/share/npm"; # `npm install -g`
    GEM_HOME = "$HOME/.local/share/gem"; # `gem install`, bundler
    BUN_INSTALL = "$HOME/.bun"; # `bun add -g`
  };
  home.sessionPath = [
    "$HOME/.local/share/npm/bin"
    "$HOME/.local/share/gem/bin"
    "$HOME/.bun/bin"
    "$HOME/go/bin" # `go install`
    "$HOME/.cargo/bin" # `cargo install`
  ];
}
