-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Copy relative file path to clipboard
vim.keymap.set("n", "<leader>fp", function()
  local path = vim.fn.expand("%")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "Copy relative file path" })

-- Switch to alternate (last opened) file
vim.keymap.set("n", "<leader><leader>", "<C-^>", { desc = "Switch to last file" })

-- Copy URL under cursor to clipboard (no browser in container)
vim.keymap.set("n", "gx", function()
  local url = vim.fn.expand("<cfile>")
  if url ~= "" then
    vim.fn.setreg("+", url)
    vim.notify("Copied: " .. url)
  end
end, { desc = "Copy URL to clipboard" })
