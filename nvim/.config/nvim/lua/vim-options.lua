vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set relativenumber")
vim.cmd("set colorcolumn=80")

vim.g.mapleader = " "
vim.g.background = "light"

vim.opt.swapfile = false

-- Navigate vim panes better
vim.keymap.set('n', '<c-k>', ':wincmd k<CR>')
vim.keymap.set('n', '<c-j>', ':wincmd j<CR>')
vim.keymap.set('n', '<c-h>', ':wincmd h<CR>')
vim.keymap.set('n', '<c-l>', ':wincmd l<CR>')

-- Centre the screen when jumping
vim.keymap.set('n', '<c-f>', '<c-f>zz')
vim.keymap.set('n', '<c-b>', '<c-b>zz')
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set('n', '<c-t>', '<c-t>zz')

-- navigate buffers with Tab
-- vim.keymap.set('n', '<tab>', ':bnext<CR>')
-- vim.keymap.set('n', '<s-tab>', ':bprevious<CR>')
vim.keymap.set("n", '<leader>abd', ':%bd|e#<CR>', {}) -- Close all buffers except the current one

-- for some reason I need to map these here rather than in the gitsigns config :thinking-face:
vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", {})
vim.keymap.set("n", "<leader>gt", ":Gitsigns toggle_current_line_blame<CR>", {})
vim.keymap.set("n", "<leader>gb", ":Gitsigns blame_line<CR>", {})
vim.keymap.set("n", "<leader>gh", ":Gitsigns preview_hunk<CR>", {})
vim.keymap.set("n", "<leader>q", ":tabclose<CR>", {})

vim.keymap.set('v', '<leader>y', '"*y')

-- Copy current buffer's filename to system clipboard
vim.keymap.set('n', '<leader>cn', function()
    local filename = vim.fn.expand('%:p')
    vim.fn.setreg('+', filename)
    print('Copied filename to clipboard: ' .. filename)
end)

vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')
vim.wo.number = true
