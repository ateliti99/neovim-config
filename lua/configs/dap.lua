local dap = require "dap"
local dapui = require "dapui"
local dap_python = require "dap-python"
local dap_cortex = require "dap-cortex-debug"

require("dapui").setup {}
require("nvim-dap-virtual-text").setup {
  commented = true, -- Show virtual text alongside comment
}

-- Setup python debugger
local py_debugger = vim.fn.stdpath "data" .. "/mason/packages/debugpy/venv/"
if jit.os == "Windows" then
  py_debugger = py_debugger .. "Scripts/python.exe"
else
  py_debugger = py_debugger .. "bin/python"
end

dap_python.setup(py_debugger)

-- C and C++ DAP configurations
dap.configurations.c = {}
dap.configurations.cpp = {}

-- Setup cortex debugger
dap_cortex.setup {
  debug = false, -- log debug messages
  lib_extension = nil, -- Shared libraries extension, tries auto-detecting, e.g. 'so' on unix
  node_path = "node", -- Path to node.js executable
  dapui_rtt = true, -- Register nvim-dap-ui RTT element
  dap_vscode_filetypes = { "c", "cpp" },
  rtt = {
    buftype = "Terminal", -- 'Terminal' or 'BufTerminal' for terminal buffer vs normal buffer
  },
}

local launch_path = vim.fn.getcwd() .. "/.vscode/launch.json"
if vim.fn.filereadable(launch_path) > 0 then
  -- Support variables for updating VSCode variables in real paths
  local stm_clt_path = "C:/ST/STM32CubeCLT_1.16.0"
  if jit.os == "Linux" then
    stm_clt_path = "mnt/c/ST/STM32CubeCLT_1.16.0"
  end
  local stm_clt_vscode = "${config:STM32VSCodeExtension.cubeCLT.path}"

  -- Read VSCode launch.json configurations
  local vscode_launch_config = vim.fn.json_decode(vim.fn.readfile(launch_path)).configurations

  -- Correct configuration from getted from VSCode
  for _, config in ipairs(vscode_launch_config) do
    config.ToolchainPath = config.armToolchainPath
    config.armToolchainPath = nil

    for key, value in pairs(config) do
      if type(value) == "string" and string.find(value, stm_clt_vscode) then
        config[key], _ = string.gsub(config[key], stm_clt_vscode, stm_clt_path)
      elseif key == "executable" then
        config[key] = "${workspaceFolder}/build/Debug/${workspaceFolderBasename}.elf"
      end
    end

    -- Insert corrected configuration
    table.insert(dap.configurations.c, config)
  end
end

-- Redefine simbols
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
