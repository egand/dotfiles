return {
  -- Completion Engine (blink.cmp)
  {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = '*',
    opts = {
      keymap = { preset = 'default' },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
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
      local lspconfig = require('lspconfig')
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      local on_attach = function(_, bufnr)
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
      end

      -- Lua (Neovim configs & plugins)
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim', 'Snacks' } },
            workspace = { checkThirdParty = false },
          },
        },
      })

      -- Nix
      lspconfig.nil_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Python
      lspconfig.pyright.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Go
      lspconfig.gopls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Java
      lspconfig.jdtls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Godot (GDScript: connects to Godot Editor embedded LSP)
      lspconfig.gdscript.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- C# (Godot .NET / Unity)
      lspconfig.csharp_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Shell / Bash
      lspconfig.bashls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
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
