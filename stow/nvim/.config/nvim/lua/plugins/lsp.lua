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
          map('gd', function() Snacks.picker.lsp_definitions() end, 'Goto Definition')
          map('gi', function() Snacks.picker.lsp_implementations() end, 'Goto Implementation')
          map('gr', function() Snacks.picker.lsp_references() end, 'Goto References')
          map('<leader>ci', function() Snacks.picker.lsp_incoming_calls() end, 'Incoming Calls (Who calls this?)')
          map('<leader>co', function() Snacks.picker.lsp_outgoing_calls() end, 'Outgoing Calls (What does this call?)')
          map('<leader>cs', function() Snacks.picker.lsp_symbols() end, 'Document Symbols / Outline')
          map('<leader>cS', function() Snacks.picker.lsp_workspace_symbols() end, 'Workspace Symbols')
          map('<leader>cr', vim.lsp.buf.rename, 'Rename Symbol')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
          map('<leader>cd', vim.diagnostic.open_float, 'Line Diagnostics Popup')
          map('gl', vim.diagnostic.open_float, 'Line Diagnostics Popup')
          map('[d', vim.diagnostic.goto_prev, 'Previous Diagnostic')
          map(']d', vim.diagnostic.goto_next, 'Next Diagnostic')
        end,
      })

      -- Default capabilities for all LSPs
      vim.lsp.config('*', {
        capabilities = capabilities,
      })

      -- Server-specific settings
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim', 'Snacks' } },
            workspace = { checkThirdParty = false },
          },
        },
      })

      vim.lsp.config('basedpyright', {
        settings = {
          basedpyright = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = 'workspace',
            },
          },
        },
      })

      -- Enable servers
      vim.lsp.enable({
        'lua_ls',
        'nil_ls',
        'basedpyright',
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

  -- Inline Symbol Usage (Shows references, definitions, and implementations above symbols)
  {
    'Wansmer/symbol-usage.nvim',
    event = 'LspAttach',
    opts = {},
  },
}
