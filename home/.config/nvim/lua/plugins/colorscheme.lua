return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    opts = {
      flavour = 'frappe', -- matches Ghostty 'Catppuccin Frappe'
      transparent_background = true,
      integrations = {
        blink_cmp = true,
        gitsigns = true,
        neogit = true,
        diffview = true,
        treesitter = true,
        which_key = true,
        snacks = true,
        lualine = true,
      },
    },
    config = function(_, opts)
      require('catppuccin').setup(opts)
      vim.cmd.colorscheme('catppuccin')
    end,
  },
}
