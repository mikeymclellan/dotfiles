
return {
  "yetone/avante.nvim",
  dir = "~/Code/avante.nvim",
  event = "VeryLazy",
  -- Avoid initializing Copilot provider when GitHub is unreachable
  enabled = function()
    -- Avante itself can run without Copilot if other providers are set.
    -- So we always enable Avante, and handle provider fallback in opts.
    return true
  end,
  version = false, -- Never set this value to "*"! Never!
  opts = function()
    local provider = 'openai'
      if os.getenv('OPENAI_API_KEY') then
        provider = 'openai'
      elseif os.getenv('ANTHROPIC_API_KEY') then
        provider = 'claude'
      elseif os.getenv('GOOGLE_API_KEY') or os.getenv('GEMINI_API_KEY') then
        provider = 'gemini'
      else
        provider = 'copilot'
      end
    return {
  debug = false,
  mode = "agentic",
  provider = provider,
  providers = {
      openai = {
        endpoint = "https://api.openai.com/v1",
        model = "gpt-4o",
        timeout = 30000,
        extra_request_body = {
          temperature = 1,
        },
      },
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-5-sonnet-latest",
        timeout = 30000,
        extra_request_body = {
          temperature = 1,
        },
      },
      gemini = {
        model = "gemini-2.5-pro-preview-06-05",
      },
      copilot = {
        endpoint = "https://api.github.com/copilot",
        model = "gemini-2.5-pro-preview-06-05",
        timeout = 30000, -- Timeout in milliseconds
        -- Do not set temperature or other unsupported params for Copilot
      },
    },
    features = {
      web_search = true,
      project_context = true,
      file_search = true,
    },
    --- Behaviour Tuning
    behaviour = {
      auto_suggestions = false, -- only on demand
      auto_focus_sidebar = true, -- jump into pane for review
      auto_apply_diff_after_generation = true, -- manual diff approval
      auto_approve_tool_permissions = true,
      enable_token_counting = false, -- see real-time usage
      cursor_planning_mode = true, -- plan-apply workflow
      minimize_diff = true, -- disable full context diffs
    },

    custom_tools = {
        {
          name = "run_unit_tests",
          description = "Run PHP unit tests and return results",  -- Description shown to AI
          command = "docker compose exec php vendor/bin/codecept run Unit",  -- Shell command to execute
          param = {  -- Input parameters (optional)
            type = "table",
            fields = {
              {
                name = "target",
                description = "Test file to run (e.g. 'tests/Unit/Promotion/Action/MultiBuyActionTest.php')",
                type = "string",
                optional = true,
              },
            },
          },
          returns = {  -- Expected return values
            {
              name = "result",
              description = "Result of the tests",
              type = "string",
            },
            {
              name = "error",
              description = "Error message if the tests were not successful",
              type = "string",
              optional = true,
            },
          },
          func = function(params, on_log, on_complete)  -- Custom function to execute
            local target = params.target or "./..."
            return vim.fn.system(string.format("docker compose exec php vendor/bin/codecept run Unit %s", target))
          end,
        },
      },
  }
  end,
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "echasnovski/mini.pick", -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        preset = "obsidian",
        file_types = { "markdown", "Avante" },
        bullet = {
            -- right_pad = 1
        },
        checkbox = {
            render_modes = false,
            -- checked = { scope_highlight = '@markup.strikethrough' },

            -- Define custom checkbox states, more involved, not part of the markdown grammar.
            -- As a result this requires neovim >= 0.10.0 since it relies on 'inline' extmarks.
            -- The key is for healthcheck and to allow users to change its values, value type below.
            -- | raw             | matched against the raw text of a 'shortcut_link'           |
            -- | rendered        | replaces the 'raw' value when rendering                     |
            -- | highlight       | highlight for the 'rendered' icon                           |
            -- | scope_highlight | optional highlight for item associated with custom checkbox |
            custom = {
                todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
                important = { raw = '[!]', rendered = '⚠️', highlight = 'RenderMarkdownImportant', scope_highlight = nil, right_pad = 1 },
                in_progress = { raw = '[~]', rendered = '⏳', highlight = 'RenderMarkdownInProgress', scope_highlight = nil },
                forwarded = { raw = '[>]', rendered = '➡️', highlight = 'RenderMarkdownForwarded', scope_highlight = nil },
            },
        }
      },
      ft = { "markdown", "Avante" },
    },
  },
}
