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
				default_tags = { "daily-notes" },
				date_format = "/%Y/%B/%Y-%m-%d",
			},
			templates = {
				folder = "Templates",
				date_format = "%A, %B %-d %Y",
				time_format = "%h:%m%a",
				substitutions = {
					["date-long"] = function()
						return os.date("%A, %B %-d %Y ", os.time())
					end,
				},
			},
		})
		vim.keymap.set("n", "<leader>od", ":ObsidianDailies<CR>", {})
		vim.keymap.set("n", "<leader>os", ":ObsidianSearch<CR>", {})
		vim.keymap.set("n", "<leader>ot", ":ObsidianTemplate<CR>", {})
	end,
}
