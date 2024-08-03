return {
   'sindrets/diffview.nvim',
    config = function()
      require('diffview').setup()
      vim.keymap.set("n", "<leader>dvh", ":DiffviewFileHistory %<CR>", {})
      vim.keymap.set("n", "<leader>dv", ":DiffviewToggleFiles<CR>", {})

   end,
}
