return {
  {
    'stevearc/oil.nvim',
    opts = { view_options = { show_hidden = true } },
    keys = {
      { '-', '<cmd>Oil<cr>', desc = 'Open Parent Directory' },
      { '<leader>o', '<cmd>Oil<cr>', desc = 'Open Parent Directory' },
    },
  },
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      explorer = { enabled = true },
      picker = {
        enabled = true,
        sources = {
          explorer = {
            ignored = true, -- Show git-ignored files and folders (e.g. plans/)
          },
        },
      },
      notifier = {
        enabled = true,
        timeout = 7000, -- Keep notifications visible for 7 seconds
      },
      input = { enabled = true },
      indent = { enabled = true },
      scroll = { enabled = true },
    },
    keys = {
      { '<leader>e', function() Snacks.explorer() end, desc = 'Toggle File Explorer' },
      { '<leader><space>', function() Snacks.picker.files() end, desc = 'Find Files' },
      { '<leader>f', function() Snacks.picker.files() end, desc = 'Find Files' },
      { '<leader>/', function() Snacks.picker.grep() end,  desc = 'Search Text' },
      { '<leader>s', function() Snacks.picker.grep() end,  desc = 'Search Text' },
      { '<leader>b', function() Snacks.picker.buffers() end, desc = 'Buffers' },
      { '<leader>sk', function() Snacks.picker.keymaps() end, desc = 'Search Keymaps' },
      { '<leader>n', function() Snacks.notifier.show_history() end, desc = 'Notification History' },
      { '<leader>un', function() Snacks.notifier.hide() end, desc = 'Dismiss Notifications' },
      { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition' },
    },
    init = function()
      vim.api.nvim_create_autocmd('VimEnter', {
        callback = function()
          -- Skip if opening git commit/rebase, in diff mode, or piping from stdin
          if vim.bo.filetype == 'gitcommit' or vim.bo.filetype == 'gitrebase' or vim.wo.diff then
            return
          end
          if vim.fn.argc() == 1 and vim.fn.argv(0) == '-' then
            return
          end
          Snacks.explorer()
        end,
      })
    end,
  },
}
