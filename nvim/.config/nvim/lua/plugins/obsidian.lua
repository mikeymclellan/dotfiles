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
                date_format = "/%Y/%B/%Y-%b-%d - %A",
            },
            templates = {
                folder = "~/Documents/Obsidian/Templates",
                date_format = "%A, %B %-d %Y",
                time_format = "%h:%m%a",
                substitutions = {
                    ["date-long"] = function()
                        return os.date("%A, %B %-d %Y ", os.time())
                    end,
                },
            },
            -- Optional, customize how note IDs are generated given an optional title.
            ---@param title string|?
            ---@return string
            note_id_func = function(title)
                -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
                -- In this case a note with the title 'My new note' will be given an ID that looks
                -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
                local suffix = ""
                if title ~= nil then
                    -- If title is given, transform it into valid file name.
                    suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", "")
                else
                    -- If title is nil, just add 4 random uppercase letters to the suffix.
                    for _ = 1, 4 do
                        suffix = suffix .. string.char(math.random(65, 90))
                    end
                end
                return os.date("%Y-%m-%d %H:%M", os.time()) .. "-" .. suffix
            end,
        })
        vim.keymap.set("n", "<leader>od", ":ObsidianDailies<CR>", {})
        vim.keymap.set("n", "<leader>os", ":ObsidianSearch<CR>", {})
        vim.keymap.set("n", "<leader>ot", ":ObsidianTemplate<CR>", {})
        vim.keymap.set("n", "<leader>on", ":ObsidianNewFromTemplate<CR>", {})
    end,
}
