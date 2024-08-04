return {
	"epwalsh/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = false,
	ft = "markdown",
	-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
	-- event = {
	--   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
	--   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
	--   -- refer to `:h file-pattern` for more examples
	--   "BufReadPre path/to/my-vault/*.md",
	--   "BufNewFile path/to/my-vault/*.md",
	-- },
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("obsidian").setup({
			workspaces = {
				{
					name = "personal",
					path = "~/Documents/Obsidian",
				},
			},
			completion = {
				-- Set to false to disable completion.
				nvim_cmp = true,
				-- Trigger completion at 2 chars.
				min_chars = 2,
			},
			daily_notes = {
				folder = "Daily",
				template = "Daily",
			},
			templates = {
				folder = "Templates",
				date_format = "%Y-%m-%d",
				time_format = "%h:%m%a",
			},
		})
		vim.keymap.set("n", "<leader>od", ":ObsidianDailies<CR>", {})
		vim.keymap.set("n", "<leader>os", ":ObsidianSearch<CR>", {})
		vim.keymap.set("n", "<leader>ot", ":ObsidianTemplate<CR>", {})
	end,
}
