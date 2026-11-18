# Neovim, configured with nixvim (https://nix-community.github.io/nixvim/).
# A nixvim module, imported by `programs.nixvim` in default.nix. Plugins come from Nix;
# nothing is downloaded at runtime. Kept lean: add plugins when they are needed.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Same colors as the terminal. Ghostty uses its default theme (no `theme` set):
  # background #282c34 and the Tomorrow Night ANSI palette.
  # Check with `ghostty +show-config --default | grep -E '^(background|foreground|palette = [0-7]=)'`.
  palette = {
    base00 = "#282c34"; # background (Ghostty `background`)
    base01 = "#31353f"; # statusline, cursorline, floats
    base02 = "#3e4451"; # selection
    base03 = "#7f848e"; # comments, line numbers
    base04 = "#abb2bf"; # dark foreground
    base05 = "#c5c8c6"; # foreground (palette 7; softer than Ghostty's #ffffff `foreground`)
    base06 = "#e0e0e0";
    base07 = "#ffffff";
    base08 = "#cc6666"; # red (palette 1)
    base09 = "#de935f"; # orange (Tomorrow Night; Ghostty's palette has none)
    base0A = "#f0c674"; # yellow (palette 3)
    base0B = "#b5bd68"; # green (palette 2)
    base0C = "#8abeb7"; # cyan (palette 6)
    base0D = "#81a2be"; # blue (palette 4)
    base0E = "#b294bb"; # magenta (palette 5)
    base0F = "#a3685a"; # brown (Tomorrow Night)
  };

  picker = fn: { __raw = "function() Snacks.${fn}() end"; };

  # nixpkgs bundles Chromium with mmdc only where Chromium builds; on macOS use the installed Chrome.
  mmdc =
    if pkgs.stdenv.hostPlatform.isDarwin then
      pkgs.writeShellScriptBin "mmdc" ''
        export PUPPETEER_EXECUTABLE_PATH="''${PUPPETEER_EXECUTABLE_PATH:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
        exec ${lib.getExe pkgs.mermaid-cli} "$@"
      ''
    else
      pkgs.mermaid-cli;
in
{
  globals = {
    mapleader = " ";
    maplocalleader = "\\";
  };

  opts = {
    number = true;
    relativenumber = true;
    signcolumn = "yes";
    cursorline = true;
    scrolloff = 4;
    wrap = false;
    splitright = true;
    splitbelow = true;
    ignorecase = true;
    smartcase = true;
    mouse = "a";
    clipboard = "unnamedplus";
    undofile = true;
    confirm = true;
    tabstop = 4;
    shiftwidth = 4;
    softtabstop = 4;
    expandtab = true;
    smartindent = true;
  };

  colorschemes.mini-base16 = {
    enable = true;
    settings = {
      inherit palette;
      # Its bufferline groups leave the tab text without a background while bufferline
      # gives the file icons one, so the tab looks patchy. Let bufferline derive them all.
      plugins = {
        default = true;
        "akinsho/bufferline.nvim" = false;
      };
    };
    # Gutter (line numbers, signs, folds) on the editor background, not on a lighter strip.
    # The cursor line keeps its highlight there (CursorLineNr, CursorLineSign).
    luaConfig.post = ''
      vim.g.colors_name = "ghostty"
      for _, name in ipairs({
        "SignColumn", "LineNr", "LineNrAbove", "LineNrBelow", "FoldColumn",
        "GitSignsAdd", "GitSignsChange", "GitSignsDelete", "GitSignsUntracked",
      }) do
        local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
        hl.bg = nil
        vim.api.nvim_set_hl(0, name, hl)
      end
    '';
  };

  plugins = {
    mini-icons = {
      enable = true;
      mockDevIcons = true;
    };
    mini-pairs.enable = true;
    which-key = {
      enable = true;
      settings.spec = [
        {
          __unkeyed-1 = "<leader>a";
          group = "ai (claude)";
        }
        {
          __unkeyed-1 = "<leader>b";
          group = "buffer";
        }
        {
          __unkeyed-1 = "<leader>c";
          group = "code";
        }
        {
          __unkeyed-1 = "<leader>f";
          group = "find";
        }
        {
          __unkeyed-1 = "<leader>g";
          group = "git";
        }
      ];
    };
    gitsigns.enable = true;
    lualine.enable = true;
    bufferline.enable = true;
    snacks = {
      enable = true;
      settings = {
        picker.enabled = true;
        explorer.enabled = true;
        lazygit.enabled = true;
        bufdelete.enabled = true;
        image.enabled = true;
      };
    };

    treesitter = {
      enable = true;
      highlight.enable = true;
      indent.enable = true;
      grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
        bash
        css
        diff
        dockerfile
        eex
        elixir
        embedded_template
        fish
        gitcommit
        go
        gomod
        gosum
        heex
        html
        javascript
        jsdoc
        json
        lua
        luadoc
        markdown
        markdown_inline
        nix
        python
        query
        regex
        ruby
        sql
        svelte
        toml
        tsx
        typescript
        vim
        vimdoc
        yaml
      ];
    };

    render-markdown = {
      enable = true;
      # "hide" conceals the closing fence, and with it the Snacks image (mermaid) drawn below
      settings.code.border = "thin";
    };

    lspconfig.enable = true; # default configs for the servers in `lsp.servers`
    blink-cmp = {
      enable = true;
      settings.keymap.preset = "enter";
    };
    conform-nvim = {
      enable = true;
      autoInstall.enable = false; # from the project's devShell
      settings = {
        notify_no_formatters = false;
        format_on_save = {
          timeout_ms = 1000;
          lsp_format = "fallback";
        };
        formatters_by_ft = {
          go = [
            "goimports"
            "gofumpt"
          ];
          python = [ "black" ];
          lua = [ "stylua" ];
          nix = [ "nixfmt" ];
          sh = [ "shfmt" ];
          htmldjango = [ "djlint" ];
          javascript = [ "prettier" ];
          javascriptreact = [ "prettier" ];
          typescript = [ "prettier" ];
          typescriptreact = [ "prettier" ];
          css = [ "prettier" ];
          html = [ "prettier" ];
          json = [ "prettier" ];
          yaml = [ "prettier" ];
          markdown = [ "prettier" ];
        };
      };
    };

    claudecode.enable = true;
  };

  # claudecode would add nixpkgs' claude-code; use the `claude` already on PATH instead.
  dependencies.claude-code.enable = false;

  withRuby = false;
  withPython3 = false;

  extraPackages = with pkgs; [
    nixfmt
    shfmt
    imagemagick # snacks image
    mmdc
  ];

  lsp = {
    servers =
      let
        fromPath = {
          enable = true;
          package = null; # from the project's devShell
        };
      in
      {
        gopls = fromPath;
        vtsls = fromPath;
        pyright = fromPath;
        ruff = fromPath;
        ruby_lsp = fromPath;
        svelte = fromPath;
        lua_ls = fromPath;
        elixirls = fromPath // {
          config.cmd = [ "elixir-ls" ]; # lspconfig has no default command for it
        };

        jsonls.enable = true;
        marksman.enable = true;
        taplo.enable = true;
        dockerls.enable = true;
        docker_compose_language_service.enable = true;
        nixd.enable = true;
        fish_lsp.enable = true; # also formats, with fish_indent
      };
    # Neovim already maps K, grn, gra, grr, gri and [d / ]d.
    keymaps = [
      {
        key = "gd";
        lspBufAction = "definition";
        options.desc = "Goto definition";
      }
      {
        key = "gr";
        action = picker "picker.lsp_references";
        options.desc = "References";
      }
      {
        key = "gy";
        lspBufAction = "type_definition";
        options.desc = "Goto type definition";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>ca";
        lspBufAction = "code_action";
        options.desc = "Code action";
      }
      {
        key = "<leader>cr";
        lspBufAction = "rename";
        options.desc = "Rename";
      }
      {
        key = "<leader>cd";
        action.__raw = "vim.diagnostic.open_float";
        options.desc = "Line diagnostics";
      }
    ];
  };

  keymaps = [
    # Find (Snacks picker)
    {
      key = "<leader><space>";
      action = picker "picker.files";
      options.desc = "Find files";
    }
    {
      key = "<leader>ff";
      action = picker "picker.files";
      options.desc = "Find files";
    }
    {
      key = "<leader>/";
      action = picker "picker.grep";
      options.desc = "Grep";
    }
    {
      key = "<leader>fb";
      action = picker "picker.buffers";
      options.desc = "Buffers";
    }
    {
      key = "<leader>fr";
      action = picker "picker.recent";
      options.desc = "Recent files";
    }
    {
      key = "<leader>e";
      action = picker "explorer";
      options.desc = "File explorer";
    }
    {
      key = "<leader>gg";
      action = picker "lazygit";
      options.desc = "Lazygit";
    }
    {
      key = "<leader>cf";
      action.__raw = "function() require('conform').format({ lsp_format = 'fallback' }) end";
      options.desc = "Format";
    }

    # Buffers and windows
    {
      key = "<S-h>";
      action = "<cmd>bprevious<cr>";
      options.desc = "Previous buffer";
    }
    {
      key = "<S-l>";
      action = "<cmd>bnext<cr>";
      options.desc = "Next buffer";
    }
    {
      key = "<leader>bd";
      action = picker "bufdelete";
      options.desc = "Delete buffer";
    }
    {
      key = "<C-h>";
      action = "<C-w>h";
    }
    {
      key = "<C-j>";
      action = "<C-w>j";
    }
    {
      key = "<C-k>";
      action = "<C-w>k";
    }
    {
      key = "<C-l>";
      action = "<C-w>l";
    }

    # Editing
    {
      mode = [
        "n"
        "i"
        "x"
        "s"
      ];
      key = "<C-s>";
      action = "<cmd>write<cr><esc>";
      options.desc = "Save";
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<esc>";
      action = "<cmd>nohlsearch<cr><esc>";
      options.desc = "Clear search highlight";
    }

    # Claude Code (claudecode.nvim)
    {
      key = "<leader>ac";
      action = "<cmd>ClaudeCode<cr>";
      options.desc = "Toggle Claude";
    }
    {
      key = "<leader>af";
      action = "<cmd>ClaudeCodeFocus<cr>";
      options.desc = "Focus Claude";
    }
    {
      key = "<leader>ab";
      action = "<cmd>ClaudeCodeAdd %<cr>";
      options.desc = "Add buffer to Claude";
    }
    {
      mode = "x";
      key = "<leader>as";
      action = "<cmd>ClaudeCodeSend<cr>";
      options.desc = "Send selection to Claude";
    }
    {
      key = "<leader>aa";
      action = "<cmd>ClaudeCodeDiffAccept<cr>";
      options.desc = "Accept diff";
    }
    {
      key = "<leader>ad";
      action = "<cmd>ClaudeCodeDiffDeny<cr>";
      options.desc = "Deny diff";
    }
  ];
}
