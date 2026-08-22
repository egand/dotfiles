return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      ensure_installed = { 'bash', 'c', 'html', 'javascript', 'json', 'lua', 'markdown', 'markdown_inline', 'nix', 'python', 'typescript', 'vim', 'yaml' },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
}
