return {
    {
        "nvim-telescope/telescope-ui-select.nvim",
    },
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.5",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                pickers = {
                    find_files = {
                        hidden = true,
                    },
                },
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown({}),
                    },
                },
            })

            local builtin = require("telescope.builtin")

            local find_all_files = function()
                -- builtin.find_files({additional_args = {"--no-ignore-vcs"}})
                builtin.find_files { find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' } }
            end

            local live_grep_all_files = function()
                builtin.live_grep({additional_args = {"--no-ignore-vcs"}})
            end

            vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
            vim.keymap.set("n", "<leader>faf", find_all_files, {})
            vim.keymap.set("n", "<leader>fw", builtin.live_grep, {})
            vim.keymap.set("n", "<leader>faw", live_grep_all_files, {})
            vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
            vim.keymap.set("n", "<leader><leader>", builtin.oldfiles, {})

            require("telescope").load_extension("ui-select")
        end,
    },
}
