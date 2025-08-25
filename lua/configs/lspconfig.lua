require("nvchad.configs.lspconfig").defaults()

local servers = { "pyright", "clangd" }

vim.lsp.config.clangd = {
  cmd = {
    "clangd",
    "--clang-tidy",
    "--background-index",
    "--offset-encoding=utf-8",
    "--background-index-priority=normal",

    -- 🎯 Specify the path to your build directory containing compile_commands.json
    -- This makes the path dynamic to the project's root folder.
    "--compile-commands-dir=./build/Debug",

    -- 🛠️ Point clangd to your cross-compiler to find system headers
    -- Replace the path with the actual path to YOUR toolchain's GCC/Clang executable.
    "--query-driver=C:/ST/STM32CubeCLT_1.16.0/GNU-tools-for-STM32/bin/arm-none-eabi-gcc.exe",
  },
  root_markers = { ".git" },
  filetypes = { "c", "cpp" },
}

vim.lsp.enable(servers)
-- read :h vim.lsp.config for changing options of lsp servers
