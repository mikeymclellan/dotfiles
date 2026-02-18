return {
    {
        "nvim-telescope/telescope-ui-select.nvim",
    },
    {
        "nvim-telescope/telescope.nvim",
        branch = "master",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    layout_config = {
                        horizontal = {
                            preview_width = 0.65, -- 65% of the width for preview
                            width = 0.95
                        },
                    },
                },
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
                builtin.find_files { find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden', '--no-ignore-vcs' } }
            end

            local live_grep_all_files = function()
                builtin.live_grep({additional_args = {'--iglob', '!.git', '--hidden', '--no-ignore-vcs'}})
            end

            vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
            vim.keymap.set("n", "<leader>fg", builtin.git_status, {})
            vim.keymap.set("n", "<leader>faf", find_all_files, {})
            vim.keymap.set("n", "<leader>fw", builtin.live_grep, {})
            vim.keymap.set("n", "<leader>faw", live_grep_all_files, {})
            vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
            vim.keymap.set("n", "<leader><leader>", builtin.oldfiles, {})

            require("telescope").load_extension("ui-select")
        end,
    },
}
