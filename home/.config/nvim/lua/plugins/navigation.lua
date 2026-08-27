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
            hidden = true, -- Show hidden dotfiles (e.g. .gitignore, .venv, .env)
            ignored = true, -- Show git-ignored files and folders (e.g. plans/)
          },
          files = {
            hidden = true, -- Show hidden files in file search
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
      { '<leader>ss', function() Snacks.picker.lsp_symbols() end, desc = 'Document Symbols' },
      { '<leader>sS', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'Workspace Symbols' },
      { '<leader>si', function() Snacks.picker.lsp_incoming_calls() end, desc = 'Incoming Calls' },
      { '<leader>so', function() Snacks.picker.lsp_outgoing_calls() end, desc = 'Outgoing Calls' },
      { '<leader>sr', function() Snacks.picker.lsp_references() end, desc = 'References' },
      { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = 'Diagnostics (Workspace)' },
      { '<leader>sD', function() Snacks.picker.diagnostics_buffer() end, desc = 'Diagnostics (Buffer)' },
      { '<leader>n', function() Snacks.notifier.show_history() end, desc = 'Notification History' },
      { '<leader>un', function() Snacks.notifier.hide() end, desc = 'Dismiss Notifications' },
      { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition' },
      { 'gr', function() Snacks.picker.lsp_references() end, desc = 'Goto References' },
      { 'gi', function() Snacks.picker.lsp_implementations() end, desc = 'Goto Implementation' },
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
  {
    'folke/trouble.nvim',
    cmd = { 'Trouble' },
    opts = {
      modes = {
        diagnostics = {
          win = { position = 'bottom', size = 10 },
        },
        symbols = {
          win = { position = 'right', size = 45 },
        },
        lsp = {
          win = { position = 'right', size = 45 },
        },
      },
    },
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle win.position=bottom win.size=10<cr>', desc = 'Diagnostics (Trouble)' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0 win.position=bottom win.size=10<cr>', desc = 'Buffer Diagnostics (Trouble)' },
      { '<leader>xs', '<cmd>Trouble symbols toggle focus=false win.position=right win.size=45<cr>', desc = 'Symbols Outline (Trouble)' },
      { '<leader>xr', '<cmd>Trouble lsp toggle focus=false win.position=right win.size=45<cr>', desc = 'LSP References / Definitions (Trouble)' },
      { '<leader>xi', '<cmd>Trouble lsp_incoming_calls toggle focus=false win.position=right win.size=45<cr>', desc = 'Incoming Calls Tree (Trouble)' },
      { '<leader>xo', '<cmd>Trouble lsp_outgoing_calls toggle focus=false win.position=right win.size=45<cr>', desc = 'Outgoing Calls Tree (Trouble)' },
    },
  },
}
