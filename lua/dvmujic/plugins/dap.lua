


return {
    "mfussenegger/nvim-dap",
    opts = function()
        local dap = require("dap")
        if not dap.adapters then dap.adapters = {} end
        dap.adapters["probe-rs-debug"] = {
            type = "server",
            port = "${port}",
            executable = {
                command = "probe-rs",
                args = { "dap-server", "--port", "${port}" },
            },
        }
        require("dap.ext.vscode").type_to_filetypes["probe-rs-debug"] = { "rust" }


        dap.listeners.before[
            "event_probe-rs-rtt-channel-config"
        ]["plugins.nvim-dap-probe-rs"] = function (session, body)
            local utils = require("dap.utils")
            utils.notify(string.format(
                "probe-rs: opening rtt channel %d with name '%s'",
                body.channelNumber, body.channelName
            ))
            session:request("rttWindowOpened", { body.channelNumber, true })
        end

        dap.listeners.before[
            "event_probe-rs-rtt-data"
        ]["plugins.nvim-dap-probe-rs"] = function(_, body)
            local message = string.format(
                "%s: rtt-channel %d - message: %s",
                os.date "%Y-%m-%d-T%H:%M:%S", body.channelNumber,
                body.data
            )
            local repl = require("dap.repl")
            repl.append(message)
        end

        dap.listeners.before[
            "event_probe-rs-show-message"
        ]["plugins.nvim-dap-probe-rs"] = function(_, body)
            local message = string.format(
                "%s: probe-rs message: %s",
                os.date "%Y-%m-%d-T%H:%M:%S", body.message
            )
            local repl = require("dap.repl")
            repl.append(message)
        end
    end
}

