-- Simple nvim setup for C, C++, Go, Rust, OCaml, Lua, Make, and Bash

-- Bootstrap lazy.nvim
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

-- Basic setup
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.termguicolors = true
vim.o.clipboard = 'unnamedplus'
vim.g.mapleader = ' '

-- Plugins
require('lazy').setup {

  -- Mason
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },

  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-lspconfig').setup {
        ensure_installed = {
          'clangd',
          'rust_analyzer',
          'gopls',
          'bashls',
          'cmake',
          'ocamllsp',
          'lua_ls',
        },
      }
    end,
  },

  -- LSP (Neovim 0.11+ API)
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      local servers = {
        'clangd',
        'rust_analyzer',
        'gopls',
        'bashls',
        'cmake',
        'ocamllsp',
      }

      for _, server in ipairs(servers) do
        vim.lsp.config(server, {
          capabilities = capabilities,
        })
        vim.lsp.enable(server)
      end

      -- lua_ls special config
      vim.lsp.config('lua_ls', {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } },
            workspace = {
              library = vim.api.nvim_get_runtime_file('', true),
            },
          },
        },
      })
      vim.lsp.enable 'lua_ls'
    end,
  },

  -- Completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
    },
    config = function()
      local cmp = require 'cmp'

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
    end,
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
  },
  { 'nvim-treesitter/nvim-treesitter-textobjects' },

  -- File explorer
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('nvim-tree').setup {
        hijack_netrw = true,
        sync_root_with_cwd = true,
      }
    end,
  },

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  -- Statusline
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup {
        options = {
          theme = 'auto',
          section_separators = '',
          component_separators = '',
        },
      }
    end,
  },

  -- Formatting
  {
    'stevearc/conform.nvim',
    config = function()
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
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      }
    end,
  },

  -- Commenting
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end,
  },

  -- Autopairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      local npairs = require 'nvim-autopairs'
      npairs.setup()

      local cmp = require 'cmp'
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },
}

-- Keybindings
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')
vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>')
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>')
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>')
vim.keymap.set('n', '<leader>fh', ':Telescope help_tags<CR>')
vim.keymap.set('n', '<leader>h', '<C-w>h')
vim.keymap.set('n', '<leader>l', '<C-w>l')

-- LSP keymaps
vim.keymap.set('n', 'gd', function()
  require('telescope.builtin').lsp_definitions()
end)
vim.keymap.set('n', 'gD', function()
  require('telescope.builtin').lsp_declarations()
end)
vim.keymap.set('n', 'gi', function()
  require('telescope.builtin').lsp_implementations()
end)
vim.keymap.set('n', 'gr', function()
  require('telescope.builtin').lsp_references()
end)
vim.keymap.set('n', '<leader>s', function()
  require('telescope.builtin').lsp_dynamic_workspace_symbols()
end)
vim.keymap.set('n', '<leader>p', vim.lsp.buf.hover)
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float)

-- Autoformat on save
vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function(args)
    require('conform').format { bufnr = args.buf, async = true }
  end,
})
