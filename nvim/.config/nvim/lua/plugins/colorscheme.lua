-- Same colors as the terminal. Ghostty uses its default theme (no `theme` set):
-- background #282c34 and the Tomorrow Night ANSI palette.
-- Check them with `ghostty +show-config --default | grep -E '^(background|foreground|palette = [0-7]=)'`.
local palette = {
  base00 = "#282c34", -- background (Ghostty `background`)
  base01 = "#31353f", -- statusline, cursorline, floats
  base02 = "#3e4451", -- selection
  base03 = "#7f848e", -- comments, line numbers
  base04 = "#abb2bf", -- dark foreground
  base05 = "#c5c8c6", -- foreground (palette 7; softer than Ghostty's #ffffff `foreground`)
  base06 = "#e0e0e0",
  base07 = "#ffffff",
  base08 = "#cc6666", -- red (palette 1)
  base09 = "#de935f", -- orange (Tomorrow Night; Ghostty's palette has none)
  base0A = "#f0c674", -- yellow (palette 3)
  base0B = "#b5bd68", -- green (palette 2)
  base0C = "#8abeb7", -- cyan (palette 6)
  base0D = "#81a2be", -- blue (palette 4)
  base0E = "#b294bb", -- magenta (palette 5)
  base0F = "#a3685a", -- brown (Tomorrow Night)
}

return {
  { "nvim-mini/mini.base16", version = false, lazy = true },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        require("mini.base16").setup({
          palette = palette,
          -- Its bufferline groups leave the tab text without a background while bufferline
          -- gives the file icons one, so the tab looks patchy. Let bufferline derive them all.
          plugins = { default = true, ["akinsho/bufferline.nvim"] = false },
        })
        vim.g.colors_name = "ghostty"

        -- Gutter (line numbers, signs, folds) on the editor background, not on a lighter strip.
        -- The cursor line keeps its highlight there (CursorLineNr, CursorLineSign).
        for _, name in ipairs({
          "SignColumn",
          "LineNr",
          "LineNrAbove",
          "LineNrBelow",
          "FoldColumn",
          "GitSignsAdd",
          "GitSignsChange",
          "GitSignsDelete",
          "GitSignsUntracked",
        }) do
          local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
          hl.bg = nil
          vim.api.nvim_set_hl(0, name, hl)
        end
      end,
    },
  },
}
