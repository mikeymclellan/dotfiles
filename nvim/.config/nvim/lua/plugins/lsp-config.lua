return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    opts = {
      auto_install = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      local lspconfig = require("lspconfig")
      lspconfig.ts_ls.setup({
        capabilities = capabilities
      })
      lspconfig.solargraph.setup({
        capabilities = capabilities
      })
      lspconfig.html.setup({
        capabilities = capabilities
      })
      lspconfig.lua_ls.setup({
        capabilities = capabilities
      })
      lspconfig.phpactor.setup({
        capabilities = capabilities
      })
      lspconfig.eslint.setup({
        capabilities = capabilities
      })
      lspconfig.gopls.setup({
        capabilities = capabilities
      })

      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
      -- vim.keymap.set("n", "<leader>gr", require("goto-preview").goto_preview_references, {})
      vim.keymap.set('n', '<leader>gr', function()
        require('telescope.builtin').lsp_references({ show_line = false })
      end, {})
      -- vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.code_action, {})
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
      vim.keymap.set('n', '<leader>s', vim.lsp.buf.signature_help, {})

      vim.diagnostic.config({
        virtual_text = {
            spacing = 4,  -- Spacing between the virtual text and the line
            source = "always", -- Show the source of the diagnostic
            severity = {
                min = vim.diagnostic.severity.WARN, -- Only show warnings and above
            },
        },
        signs = true,  -- Show signs in the sign column
        underline = false,  -- Underline the text with diagnostics
        update_in_insert = false,  -- Update diagnostics in insert mode
        severity_sort = true,  -- Sort diagnostics by severity
      })
      vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#ff0000", bg = "NONE", italic = true, blend = 70 })
      vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn",  { fg = "#ffaa00", bg = "NONE", italic = true, blend = 70 })
      vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo",  { fg = "#00aaff", bg = "NONE", italic = true, blend = 70 })
      vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint",  { fg = "#00ffaa", bg = "NONE", italic = true, blend = 70 })

        local suppressed_patterns = {
            "scanned %d+ references confirmed %d+",
            "Found %d+ reference%(s%)",
        }

        -- Custom handler to filter Phpactor messages
        local function suppress_phpactor_logs(original_handler)
            return function(err, result, ctx, config)
                local client = vim.lsp.get_client_by_id(ctx.client_id)
                if client and client.name == "phpactor" then
                    for _, pat in ipairs(suppressed_patterns) do
                        if type(result.message) == "string" and result.message:match(pat) then
                            return  -- Suppress this message
                        end
                    end
                end
                return original_handler(err, result, ctx, config)
            end
        end

        -- Override the log message and show message handlers
        vim.lsp.handlers["window/logMessage"] = suppress_phpactor_logs(vim.lsp.handlers["window/logMessage"])
        vim.lsp.handlers["window/showMessage"] = suppress_phpactor_logs(vim.lsp.handlers["window/showMessage"])

    end,
  },
  {
    "rmagatti/goto-preview",
    event = "BufEnter",
    config = function()
      require("goto-preview").setup()
      vim.keymap.set("n", "<leader>pd", require("goto-preview").goto_preview_definition, {})
      vim.keymap.set("n", "<leader>pr", require("goto-preview").goto_preview_references, {})
    end,
  }
}
