-- Save file with leader + w
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>', { desc = 'Save File' })

-- Escape clears search highlighting and redraws screen to remove visual artifacts
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR><cmd>redraw!<CR>', { desc = 'Clear Search Highlights & Redraw' })

-- Select all
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select All' })

-- Window navigation (switch between explorer sidebar and code editor)
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Focus Left Window (Explorer)' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Focus Right Window (Code)' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Focus Lower Window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Focus Upper Window' })

-- Window resizing (hold Ctrl + Shift and press Arrow keys)
vim.keymap.set('n', '<C-S-Up>', '<cmd>resize -2<CR>', { desc = 'Move Horizontal Border Up' })
vim.keymap.set('n', '<C-S-Down>', '<cmd>resize +2<CR>', { desc = 'Move Horizontal Border Down' })
vim.keymap.set('n', '<C-S-Left>', '<cmd>vertical resize -5<CR>', { desc = 'Move Vertical Border Left' })
vim.keymap.set('n', '<C-S-Right>', '<cmd>vertical resize +5<CR>', { desc = 'Move Vertical Border Right' })

-- Pasting over a selection no longer clobbers clipboard
vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])

-- Navigate wrapped lines naturally (press j/k to move visually, count + j/k to move physical lines)
vim.keymap.set({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = 'Down (Visual Line)' })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = 'Up (Visual Line)' })
