require "nvchad.options"

local o = vim.o
local system = jit.os

if system == "Windows" then
  vim.o.shell = "powershell"
end
