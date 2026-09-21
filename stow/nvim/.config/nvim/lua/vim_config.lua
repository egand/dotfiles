local o = vim.opt
vim.g.mapleader = ' '          -- space is the leader key
o.expandtab = true             -- spaces, not tabs
o.shiftwidth = 2               -- 2 spaces per indent level
o.number = true                -- absolute number on the cursor line, relative elsewhere
o.relativenumber = true        -- relative line numbers for fast jumps
o.ignorecase = true            -- search is case-insensitive by default
o.smartcase = true             -- case-sensitive only if i type a capital
o.clipboard = 'unnamedplus'    -- share the system clipboard
o.scrolloff = 16               -- keep cursor away from the screen edge
o.undofile = true              -- persistent undo across sessions
o.mouse = ''                   -- no mouse in nvim; also lets Herdr keep host mouse capture off so Escape isn't swallowed
o.wrap = true                  -- wrap long lines visually
o.linebreak = true             -- wrap at word boundaries rather than middle of words
o.breakindent = true           -- preserve indentation on wrapped lines
o.autoread = true              -- auto-reload files changed outside neovim (e.g. by AI agents or git)

-- Automatically trigger buffer & git status refresh on focus, buffer switch, and idle cursor
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold' }, {
  desc = 'Check if buffers were modified externally',
  callback = function()
    if vim.fn.getcmdwintype() == '' then
      vim.cmd('checktime')
    end
  end,
})
