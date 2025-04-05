return {
  "stevearc/conform.nvim",
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        -- Conform will run multiple formatters sequentially
        python = { "isort", "black" },
        -- You can customize some of the format options for the filetype (:help conform.format)
        rust = { "rustfmt", lsp_format = "fallback" },
        -- Conform will run the first available formatter
        javascript = { "prettierd", "prettier", stop_after_first = true },
        php = { "php-cs-fixer" }, -- Add PHP formatter
      },
    })
    vim.keymap.set("n", "<leader>fr", require("conform").format, {})

  end,
  event = "BufReadPre", -- Load the plugin when a buffer is read
}
