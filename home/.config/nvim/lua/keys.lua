-- Save file with leader + w
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>', { desc = 'Save File' })

-- Escape clears search highlighting
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear Search Highlights' })

-- Select all
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select All' })

-- Window navigation (switch between explorer sidebar and code editor)
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Focus Left Window (Explorer)' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Focus Right Window (Code)' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Focus Lower Window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Focus Upper Window' })

-- Pasting over a selection no longer clobbers clipboard
vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])

-- Navigate wrapped lines naturally (press j/k to move visually, count + j/k to move physical lines)
vim.keymap.set({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = 'Down (Visual Line)' })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = 'Up (Visual Line)' })
