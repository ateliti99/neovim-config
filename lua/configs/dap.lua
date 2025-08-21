local dap = require "dap"
local dapui = require "dapui"
local dap_python = require "dap-python"

require("dapui").setup {}
require("nvim-dap-virtual-text").setup {
  commented = true, -- Show virtual text alongside comment
}

local py_debugger = vim.fn.stdpath "data" .. "/mason/packages/debugpy/venv/"
if jit.os == "Windows" then
  py_debugger = py_debugger .. "Scripts/python.exe"
else
  py_debugger = py_debugger .. "bin/python"
end

dap_python.setup(py_debugger)

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
