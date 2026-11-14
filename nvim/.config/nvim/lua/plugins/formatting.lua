return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        html = { "prettier" },
        htmldjango = { "djlint" },
        css = { "prettier" },
        javascript = { "prettier" },
        python = { "black" },
      },
    },
  },
}
