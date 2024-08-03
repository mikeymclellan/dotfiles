return {
  "akinsho/toggleterm.nvim",

    config = function()
        require("toggleterm").setup();
        local Terminal = require("toggleterm.terminal").Terminal
        local lazygit_group
        local lazygit = Terminal:new({
            cmd = "/opt/homebrew/bin/lazygit", --  --use-config-file=$HOME/.config/lazygit/config.yml",
            direction = "float",
            -- hidden = true,
        })

        local function lazygit_toggle()
            lazygit:toggle()
        end

        vim.keymap.set("n", "<leader>lg", lazygit_toggle, { noremap = true, silent = true })

    end
}
