return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "theHamsta/nvim-dap-virtual-text",
        "nvim-neotest/nvim-nio",
    },
    config = function ()
        local dap, dapui = require("dap"), require("dapui")
        dapui.setup()

        vim.keymap.set('n', '<Leader>xb', function() dap.toggle_breakpoint() end)
        vim.keymap.set('n', '<Leader>xt', function() dapui.toggle() end)

        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end

        dap.adapters.php = {
            type = 'executable',
            command = 'node',
            args = { '/Users/mikey/Code/vscode-php-debug/out/phpDebug.js' }
        }

        dap.configurations.php = {
            {
                type = 'php',
                request = 'launch',
                name = 'Listen for Xdebug',
                port = 9003,
                pathMappings = {
                    ['/srv/sylius'] = "${workspaceFolder}",
                },
            }
        }

    end
}
