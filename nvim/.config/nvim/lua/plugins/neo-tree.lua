return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
        require("neo-tree").setup({
            filesystem = {
                follow_current_file = { enabled = true},
                commands = {
                    avante_add_files = function(state)
                        local node = state.tree:get_node()
                        local filepath = node:get_id()
                        local relative_path = require('avante.utils').relative_path(filepath)

                        local sidebar = require('avante').get()

                        local open = sidebar:is_open()
                        -- ensure avante sidebar is open
                        if not open then
                            require('avante.api').ask()
                            sidebar = require('avante').get()
                        end

                        sidebar.file_selector:add_selected_file(relative_path)

                        -- remove neo tree buffer
                        if not open then
                            sidebar.file_selector:remove_selected_file('neo-tree filesystem [1]')
                        end
                    end,
                },
                window = {
                    mappings = {
                        ['oa'] = 'avante_add_files',
                        -- Explicitly set <CR> to prevent obsidian.nvim from overriding
                        ['<CR>'] = 'open',
                    },
                },
            }
        });
        vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>", {})
        vim.keymap.set("n", "<leader>b", ":Neotree buffers reveal float<CR>", {})

	end,
}
