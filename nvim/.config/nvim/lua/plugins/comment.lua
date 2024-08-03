
return {
  {
    "numToStr/Comment.nvim",
    config = function()
      require('Comment').setup()
      -- vim.keymap.set("n", "<leader>/", ":lua require('Comment.api').toggle()<CR>")
      vim.keymap.set("n", "<leader>/", "gcc", {remap = true})
      vim.keymap.set("v", "<leader>/", "gbc<esc>", {remap = true})
    end,
  }
}

