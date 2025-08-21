local dap = require "dap"
local dapui = require "dapui"
local dap_python = require "dap-python"

require("dapui").setup {}
require("nvim-dap-virtual-text").setup {
  commented = true, -- Show virtual text alongside comment
}

-- dap_python.setup "/home/ateliti/.local/share/nvim/mason/packages/debugpy/venv/bin/python"

local mason_path = vim.fn.stdpath "data" .. "/mason/packages/debugpy/venv/"
if jit.os == "Windows" then
  mason_path = mason_path .. "Scripts/python.exe"
else
  mason_path = mason_path .. "bin/python"
end

dap.adapters.python = function(cb, config)
  if config.request == "attach" then
    ---@diagnostic disable-next-line: undefined-field
    local port = (config.connect or config).port
    ---@diagnostic disable-next-line: undefined-field
    local host = (config.connect or config).host or "127.0.0.1"
    cb {
      type = "server",
      port = assert(port, "`connect.port` is required for a python `attach` configuration"),
      host = host,
      options = {
        source_filetype = "python",
      },
    }
  else
    cb {
      type = "executable",
      command = mason_path,
      args = { "-m", "debugpy.adapter" },
      options = {
        source_filetype = "python",
      },
    }
  end
end

dap.configurations.python = {
  {
    -- The first three options are required by nvim-dap
    type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
    request = "launch",
    name = "Launch file",

    -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

    program = "${file}", -- This configuration will launch the current file if used.
    pythonPath = function()
      local cwd = vim.fn.getcwd()
      local system = jit.os

      if system == "Windows" then
        if vim.fn.executable(cwd .. "\\venv\\Scripts\\python") == 1 then
          return cwd .. "\\venv\\Scripts\\python"
        elseif vim.fn.executable(cwd .. "\\.venv\\Scripts\\python") == 1 then
          return cwd .. "\\.venv\\Scripts\\python"
        else
          return "python"
        end
      else
        if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
          return cwd .. "/venv/bin/python"
        elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
          return cwd .. "/.venv/bin/python"
        else
          return "python3"
        end
      end
    end,
  },
}

vim.fn.sign_define("DapBreakpoint", {
  text = "",
  texthl = "DiagnosticSignError",
  linehl = "",
  numhl = "",
})

vim.fn.sign_define("DapBreakpointRejected", {
  text = "", -- or "❌"
  texthl = "DiagnosticSignError",
  linehl = "",
  numhl = "",
})

vim.fn.sign_define("DapStopped", {
  text = "", -- or "→"
  texthl = "DiagnosticSignWarn",
  linehl = "Visual",
  numhl = "DiagnosticSignWarn",
})

-- Automate opening and closing of the UI
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

local opts = { noremap = true, silent = true }

-- Toggle a breakpoint on the current line
vim.keymap.set("n", "<leader>db", function()
  require("dap").toggle_breakpoint()
end, { desc = "Toggle Breakpoint" })

-- Start the debugger or continue to the next breakpoint
vim.keymap.set("n", "<leader>dc", function()
  require("dap").continue()
end, { desc = "Continue / Start Debugger" })

-- Step over the current line, without entering function calls
vim.keymap.set("n", "<leader>do", function()
  require("dap").step_over()
end, { desc = "Step Over" })

-- Step into a function call on the current line
vim.keymap.set("n", "<leader>di", function()
  require("dap").step_into()
end, { desc = "Step Into" })

-- Step out of the current function
vim.keymap.set("n", "<leader>dO", function()
  require("dap").step_out()
end, { desc = "Step Out" })

-- Terminate the current debugging session
vim.keymap.set("n", "<leader>dq", function()
  require("dap").terminate()
end, { desc = "Terminate Debugging" })

-- Toggle the visibility of the DAP user interface
vim.keymap.set("n", "<leader>du", function()
  require("dapui").toggle()
end, { desc = "Toggle DAP UI" })
