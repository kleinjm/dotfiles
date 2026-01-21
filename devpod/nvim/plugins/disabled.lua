return {
  { "akinsho/bufferline.nvim", enabled = false },
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = false },
      picker = {
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
