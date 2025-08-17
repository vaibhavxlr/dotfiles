-- Minimal VSCode/Zed-like Neovim config
-- Supports: Rust, C, C++, Go, Makefiles, Bash, OCaml, Lua
-- With auto-format on save

-- Bootstrap lazy.nvim if needed
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require('lazy').setup {
  -- LSP
  { 'neovim/nvim-lspconfig' },
  { 'williamboman/mason.nvim', config = true },
  { 'williamboman/mason-lspconfig.nvim' },

  -- Completion
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-buffer' },
  { 'hrsh7th/cmp-path' },
  { 'L3MON4D3/LuaSnip' },

  -- File explorer
  { 'nvim-tree/nvim-tree.lua', dependencies = { 'nvim-tree/nvim-web-devicons' } },

  -- Fuzzy finder
  { 'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' } },

  -- Status line
  { 'nvim-lualine/lualine.nvim' },

  -- Formatter
  { 'stevearc/conform.nvim' },
}

require('nvim-tree').setup()

-- General settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.termguicolors = true -- still uses terminal colors
vim.o.clipboard = 'unnamedplus'

-- Leader key
vim.g.mapleader = ' '

-- Keymaps
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })
vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>', { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>', { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', ':Telescope help_tags<CR>', { desc = 'Find help' })
-- Go to left window (nvim-tree)
vim.keymap.set('n', '<leader>h', '<C-w>h', { desc = 'Focus left window' })
-- Go to right window (editor)
vim.keymap.set('n', '<leader>l', '<C-w>l', { desc = 'Focus right window' })

-- Setup LSP
local lspconfig = require 'lspconfig'
local cmp = require 'cmp'
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('mason-lspconfig').setup {
  ensure_installed = {
    'clangd', -- C/C++
    'rust_analyzer', -- Rust
    'gopls', -- Go
    'bashls', -- Bash
    'cmake', -- CMake / Makefiles
    'ocamllsp', -- OCaml
    'lua_ls', -- Lua (for config)
  },
}

-- Loop through servers and setup
local servers = { 'clangd', 'rust_analyzer', 'gopls', 'bashls', 'cmake', 'ocamllsp', 'lua_ls' }
for _, server in ipairs(servers) do
  lspconfig[server].setup {
    capabilities = capabilities,
  }
end

-- Autocompletion setup
cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm { select = true },
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
  },
}

-- Statusline
require('lualine').setup {
  options = {
    theme = 'auto', -- respects terminal colors
    section_separators = '',
    component_separators = '',
  },
}

-- Formatting (conform.nvim)
require('conform').setup {
  formatters_by_ft = {
    lua = { 'stylua' },
    rust = { 'rustfmt' },
    c = { 'clang_format' },
    cpp = { 'clang_format' },
    go = { 'gofmt' },
    sh = { 'shfmt' },
    ocaml = { 'ocamlformat' },
  },
}

-- Auto-format on save
vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function(args)
    require('conform').format { bufnr = args.buf }
  end,
})
