local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },
    c = { "clang-format" },
    cpp = { "clang-format" },
  },

  -- Configure individual formatters
  formatters = {
    black = {
      command = "black",
      args = function(ctx)
        local fname = ctx and ctx.filename or vim.api.nvim_buf_get_name(ctx.bufnr or 0)
        return { "--quiet", "--line-length", "88", "--stdin-filename", fname, "-" }
      end,
    },

    isort = {
      command = "isort",
      args = function(ctx)
        local fname = ctx and ctx.filename or vim.api.nvim_buf_get_name(ctx.bufnr or 0)
        return { "--profile", "black", "--line-width", "88", "-" }
      end,
    },

    -- ["clang-format"] = {
    --   command = "clang-format",
    --   args = function(ctx)
    --     local fname = ctx and ctx.filename or vim.api.nvim_buf_get_name(ctx.bufnr or 0)
    --     local style = "{BasedOnStyle: LLVM,"
    --       .. " UseTab: Never,"
    --       .. " IndentWidth: 4,"
    --       .. " TabWidth: 4,"
    --       .. " BreakBeforeBraces: Allman,"
    --       .. " PointerAlignment: Right,"
    --       .. " ColumnLimit: 80,"
    --       .. " FixNamespaceComments: false,"
    --       .. " AllowShortFunctionsOnASingleLine: Inline,"
    --       .. " AllowShortBlocksOnASingleLine: false,"
    --       .. " ReflowComments: false}"
    --     return { "--assume-filename=" .. fname, "--style=" .. style, "-" }
    --   end,
    -- },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 100000,
    lsp_fallback = false,
  },
}

return options
