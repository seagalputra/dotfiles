-- Dependencies
local use = require('packer').use
require('packer').startup(function()
  use 'wbthomason/packer.nvim'
  use 'neovim/nvim-lspconfig'
  use 'williamboman/nvim-lsp-installer'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'saadparwaiz1/cmp_luasnip'
  use 'L3MON4D3/LuaSnip'
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use { 'fatih/vim-go', run = ':GoUpdateBinaries' }
  use { 'catppuccin/nvim', as = 'catppuccin' }
  use { 'kyazdani42/nvim-web-devicons' }
  use 'lukas-reineke/indent-blankline.nvim'
  use {
    'romgrk/barbar.nvim',
    requires = {'kyazdani42/nvim-web-devicons'}
  }
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  use 'simrat39/symbols-outline.nvim'
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons',
    },
  }
  use 'lewis6991/gitsigns.nvim'
end)

-- Editor
local set = vim.opt
-- vim.cmd('syntax on')
vim.cmd('filetype plugin indent on')

vim.g.mapleader = '\\'
set.number = true
set.clipboard = 'unnamedplus'
set.backspace = { 'indent', 'eol', 'start' }
set.expandtab = true
set.tabstop = 2
set.shiftwidth = 2
set.softtabstop = 2
set.incsearch = true
set.hlsearch = true
set.modelines = 1
set.sidescroll = 1
vim.wo.wrap = false
vim.bo.fixendofline = false
set.mouse = 'a'

set.list = true
set.listchars:append("space:⋅")

require('indent_blankline').setup {
  space_char_blankline = " ",
  show_current_context = true,
  show_current_context_start = true,
}

-- Theme
set.background = 'dark'
vim.g.catppuccin_flavour = 'macchiato'
vim.cmd[[colorscheme catppuccin]]

-- Lualine
require('lualine').setup{
  options = {
    theme = 'catppuccin'
  }
}

-- Language Server
require('nvim-lsp-installer').setup{}

local on_attach = function (client, bufnr)
  -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local lspconfig = require('lspconfig')

local servers = { 'pyright', 'rust_analyzer', 'tsserver' }
for _, lsp in pairs(servers) do
  lspconfig[lsp].setup{
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150
    }
  }
end

local luasnip = require'luasnip'

local cmp = require'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- Treesitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = { 'lua', 'ruby', 'python', 'rust', 'javascript', 'typescript', 'go' },
  sync_install = false,
  highlight = {
    enable = true
  }
}

-- Nvim Tree
require'nvim-tree'.setup{
  auto_reload_on_write = true,
  reload_on_bufenter = true,
}

-- Gitsigns
require'gitsigns'.setup()

-- Keymaps
vim.keymap.set('n', '<leader>/', ':nohlsearch<CR>')
vim.keymap.set('n', '<leader>s', ':source init.lua<CR>')

local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

local telescope = require('telescope.builtin')
vim.keymap.set('n', '<space>p', telescope.find_files)
vim.keymap.set('n', '<space>g', telescope.live_grep)
vim.keymap.set('n', '<space>b', telescope.buffers)
vim.keymap.set('n', '<space>h', telescope.help_tags)

vim.keymap.set('n', '<space>s', ':SymbolsOutline<CR>')

vim.keymap.set('n', '<space>n', ':NvimTreeToggle<CR>')

-- Config Group
local autocmd_config = {
  {
    type = 'VimEnter',
    pattern = '*',
    opts = {
      { command = 'highlight clear SignColumn' }
    }
  },
  {
    type = 'FileType',
    pattern = 'ruby',
    opts = {
      { command = 'setlocal tabstop=2' },
      { command = 'setlocal shiftwidth=2' },
      { command = 'setlocal softtabstop=2' },
      { command = 'setlocal commentstring=#\\ %s' },
    },
  },
  {
    type = 'BufEnter',
    pattern = '*.sh',
    opts = {
      { command = 'setlocal tabstop=2' },
      { command = 'setlocal shiftwidth=2' },
      { command = 'setlocal softtabstop=2' },
    },
  },
  {
    type = 'FileType',
    pattern = 'json',
    opts = {
      { command = 'setlocal tabstop=2' },
      { command = 'setlocal shiftwidth=2' },
      { command = 'setlocal softtabstop=2' },
    },
  },
  {
    type = 'FileType',
    pattern = 'typescript',
    opts = {
      { command = 'setlocal tabstop=2' },
      { command = 'setlocal shiftwidth=2' },
      { command = 'setlocal softtabstop=2' },
    },
  },
  {
    type = 'FileType',
    pattern = 'javascript',
    opts = {
      { command = 'setlocal tabstop=2' },
      { command = 'setlocal shiftwidth=2' },
      { command = 'setlocal softtabstop=2' },
    },
  },
  {
    type = 'FileType',
    pattern = 'php',
    opts = {
      { command = 'setlocal tabstop=2' },
      { command = 'setlocal shiftwidth=2' },
      { command = 'setlocal softtabstop=2' },
    },
  },
  {
    type = 'FileType',
    pattern = 'go',
    opts = {
      { command = 'setlocal tabstop=4' },
      { command = 'setlocal shiftwidth=4' },
      { command = 'setlocal softtabstop=4' },
    },
  },
  {
    type = 'FileType',
    pattern = 'sql',
    opts = {
      { command = 'setlocal tabstop=4' },
      { command = 'setlocal shiftwidth=4' },
      { command = 'setlocal softtabstop=4' },
    },
  },
  {
    type = 'BufNewFile,BufRead',
    pattern = '*.py',
    opts = {
      { command = 'set tabstop=4' },
      { command = 'set shiftwidth=4' },
      { command = 'set softtabstop=4' },
      { command = 'set textwidth=79' },
      { command = 'set expandtab' },
      { command = 'set autoindent' },
      { command = 'set fileformat=unix' },
    },
  },
}
local augroup = vim.api.nvim_create_augroup('config_group', { clear = true })
for _, config in pairs(autocmd_config) do
  for _, opts in pairs(config.opts) do
    vim.api.nvim_create_autocmd(config.type, {
      pattern = config.pattern,
      group = augroup,
      command = opts.command
    })
  end
end

