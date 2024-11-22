require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Format commands
map("n", "<leader>fm", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "LSP formatting" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
