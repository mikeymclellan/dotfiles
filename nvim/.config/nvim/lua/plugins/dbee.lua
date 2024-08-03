return {
    "kndndrj/nvim-dbee",
    dependencies = {
        "MunifTanjim/nui.nvim",
    },
    build = function()
        require("dbee").install()
    end,
    config = function()
        require("dbee").setup({
            default_connection = "subscription-localhost",
            editor = {
                mappings = {
                    -- run what's currently selected on the active connection
                    { key = "<cr>", mode = "v", action = "run_selection" },
                    -- run the whole file on the active connection
                    { key = "BsdkjfhkdsjhgjkdfsB", mode = "n", action = "run_file" },
                }
            },
            result = {
                mappings = {
                    { key = "yac", mode = "n", action = "yank_current_csv" },
                    { key = "y", mode = "v", action = "yank_selection_csv" },
                    { key = "yy", mode = "", action = "yank_all_csv" },
                }
            }
        })
        vim.keymap.set("n", "<leader>db", ":Dbee<CR>", {})
    end
}
