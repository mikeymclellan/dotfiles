return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        auto_install = true,
        highlight = {
          enable = true,
          -- Workaround: avoid occasional extmark range errors in Markdown
          -- See: Invalid 'end_col': out of range from Treesitter highlighter
          disable = { "markdown", "markdown_inline" },
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
          -- Indent queries for Markdown are unstable in some versions
          disable = { "markdown" },
        },
      })
    end
  }
}
