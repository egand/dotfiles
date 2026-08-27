return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = false,
    config = function()
      local ts = require('nvim-treesitter')
      ts.setup({})

      -- Auto-enable treesitter highlighting when opening buffers
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })

      -- Ensure required parsers are installed only if missing
      local installed = ts.get_installed()
      local desired = {
        'bash',
        'c',
        'html',
        'javascript',
        'json',
        'lua',
        'markdown',
        'markdown_inline',
        'nix',
        'python',
        'typescript',
        'vim',
        'yaml',
      }
      local missing = vim.tbl_filter(function(lang)
        return not vim.list_contains(installed, lang)
      end, desired)
      if #missing > 0 then
        ts.install(missing)
      end
    end,
  },

  -- Treesitter Context (Sticky header showing enclosing function/class when scrolling)
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      max_lines = 4,
      trim_scope = 'outer',
      mode = 'cursor',
    },
    keys = {
      {
        '[c',
        function()
          require('treesitter-context').go_to_context(vim.v.count1)
        end,
        desc = 'Jump to Context Header',
      },
    },
  },
}
