return {
  { "akinsho/bufferline.nvim", enabled = false },
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = false },
      picker = {
        sources = {
          files = {
            hidden = true,
          },
        },
        win = {
          input = {
            keys = {
              ["<C-n>"] = { "edit_tab", mode = { "i", "n" } },
            },
          },
        },
      },
    },
  },
}
