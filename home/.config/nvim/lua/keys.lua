-- Save file with leader + w
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>', { desc = 'Save File' })

-- Escape clears search highlighting
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear Search Highlights' })

-- Select all
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select All' })

-- Pasting over a selection no longer clobbers clipboard
vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])
