return {
  -- Completion Engine (blink.cmp)
  {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = '*',
    opts = {
      keymap = { preset = 'default' },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      signature = { enabled = true },
    },
  },

  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'saghen/blink.cmp' },
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Global LSP Keybindings on attach
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local bufnr = args.buf
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
          end

          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('gD', vim.lsp.buf.declaration, 'Goto Declaration')
          map('gi', vim.lsp.buf.implementation, 'Goto Implementation')
          map('gr', vim.lsp.buf.references, 'Goto References')
          map('<leader>cr', vim.lsp.buf.rename, 'Rename Symbol')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
          map('[d', vim.diagnostic.goto_prev, 'Previous Diagnostic')
          map(']d', vim.diagnostic.goto_next, 'Next Diagnostic')
        end,
      })

      -- Default capabilities for all LSPs
      vim.lsp.config('*', {
        capabilities = capabilities,
      })

      -- Server-specific settings
      vim.lsp.config['lua_ls'] = {
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim', 'Snacks' } },
            workspace = { checkThirdParty = false },
          },
        },
      }

      -- Enable servers
      vim.lsp.enable({
        'lua_ls',
        'nil_ls',
        'pyright',
        'gopls',
        'jdtls',
        'gdscript',
        'csharp_ls',
        'bashls',
      })
    end,
  },

  -- Formatting (conform.nvim)
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    opts = {
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'ruff_format', 'ruff_organize_imports' },
        nix = { 'nixfmt' },
        sh = { 'shfmt' },
        go = { 'gofmt' },
      },
    },
  },
}
