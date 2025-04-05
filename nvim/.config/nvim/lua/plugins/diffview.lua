return {
    "sindrets/diffview.nvim",
    config = function()
        local actions = require("diffview.actions");
        require("diffview").setup({
            keymaps = {
                file_history_panel = {
                    {
                        "n",
                        "<leader>gl",
                        actions.open_in_diffview,
                        { desc = "Open the entry under the cursor in a diffview" },
                    },
                },
            },
        })
        vim.keymap.set("n", "<leader>gl", ":DiffviewFileHistory %<CR>", {})
        vim.keymap.set("n", "<leader>gv", ":DiffviewOpen<CR>", {})
    end,
}
