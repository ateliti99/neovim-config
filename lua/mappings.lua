require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("t", "<Esc><Esc>", [[<C-\><C-n>:q<CR>]], { desc = "Quit terminal with Esc Esc" })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
