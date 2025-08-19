require "nvchad.mappings"

-- Keymaps
local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("t", "<Esc><Esc>", [[<C-\><C-n>:q<CR>]], { desc = "Quit terminal with Esc Esc" })

-- Commands
local create_command = vim.api.nvim_create_user_command

-- Command to build a project from a CMakeLists.txt from CMake configuration in STM32CubeMX
create_command("BuildProject", function(opts)
  local system = jit.os

  -- If clean is given clean the build folder
  if opts.args == "clean" then
    print "Cleaning the build folder..."
    vim.system({ "rm", "-r", "build" }):wait()
  end

  -- Ensure build folder exists
  if vim.fn.isdirectory "build" == 0 then
    vim.fn.mkdir("build", "p")
  end

  -- Choose cmake binary depending on system
  local cmake = (system == "Windows") and "cmake" or "/mnt/c/ST/STM32CubeCLT_1.16.0/CMake/bin/cmake.exe"
  local on_exit = function(obj)
    print(obj.stdout)
  end

  -- Run configure
  print "Genereting CMake from the CMakeLists..."
  vim
    .system({
      cmake,
      "-DCMAKE_TOOLCHAIN_FILE=cmake/gcc-arm-none-eabi.cmake",
      "-S",
      ".",
      "-B",
      "build/Debug",
      "-G",
      "Ninja",
    }, {}, on_exit)
    :wait()

  -- Run build
  print "Building...\n"
  vim.system({ cmake, "--build", "build/Debug" }, {}, on_exit):wait()

  print "Finish building the project!"
end, {
  bang = false,
  desc = "Build a project from CMakeLists.txt on Windows or WSL",
  nargs = "?",
})

create_command("FlashProject", function()
  local system = jit.os
  local stm32_cli = (system == "Windows") and "STM32_Programmer_CLI"
    or "/mnt/c/ST/STM32CubeCLT_1.16.0/STM32CubeProgrammer/bin/STM32_Programmer_CLI.exe"
  local on_exit = function(obj)
    print(obj.stdout)
  end
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  local args = {
    "--connect",
    "port=swd",
    "--download",
    project_name,
    "-hardRst",
    "-rst",
    "--start",
  }

  -- Run STM32_Programmer_CLI
  print "Start flashing"
  vim.system({ stm32_cli, unpack(args) }, {}, on_exit):wait()
  print "Flashing complete!"
end, {})
