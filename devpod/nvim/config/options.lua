-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Enable word wrap
vim.opt.wrap = true
vim.opt.linebreak = true

-- Show tabline when 2+ tabs open
vim.opt.showtabline = 1

-- Use OSC 52 for clipboard (works in containers via terminal)
vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
    ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
  },
}
