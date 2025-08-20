require "nvchad.mappings"

-- Keymaps
local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("t", "<Esc><Esc>", [[<C-\><C-n>:q<CR>]], { desc = "Quit terminal with Esc Esc" })
