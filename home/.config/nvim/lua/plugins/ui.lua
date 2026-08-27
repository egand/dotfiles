return {
  -- Which-key (Popup keybinding helper)
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'modern',
      spec = {
        { '<leader>c', group = 'code / lsp' },
        { '<leader>g', group = 'git' },
        { '<leader>s', group = 'search' },
        { '<leader>u', group = 'ui / toggles' },
        { '<leader>x', group = 'trouble / diagnostics' },
      },
    },
  },

  -- Icons
  {
    'nvim-tree/nvim-web-devicons',
    lazy = true,
    opts = {},
  },

  -- Statusline (Lualine)
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'catppuccin-frappe',
        globalstatus = true,
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  -- Autopairs (Auto-close brackets and quotes)
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },

  -- Flash (Lightning-fast search navigation by Folke)
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
      { 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash Jump' },
      { 'S', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end, desc = 'Flash Treesitter' },
      { 'r', mode = 'o', function() require('flash').remote() end, desc = 'Remote Flash' },
      { 'R', mode = { 'o', 'x' }, function() require('flash').treesitter_search() end, desc = 'Treesitter Search' },
    },
  },

  -- Render Markdown (In-buffer rich Markdown rendering)
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ft = { 'markdown', 'Avante' },
    opts = {
      heading = {
        icons = { '󰉫 ', '󰉬 ', '󰉭 ', '󰉮 ', '󰉯 ', '󰉰 ' },
      },
      bullet = {
        icons = { '●', '○', '◆', '◇' },
      },
    },
  },
}
