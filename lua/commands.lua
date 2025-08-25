local create_command = vim.api.nvim_create_user_command
local terminal = require "nvchad.term"

-- Helper to run a command in a floating terminal
local function run_in_terminal(cmd)
  terminal.toggle { pos = "float", id = "floatTerm" }
  vim.cmd "startinsert"
  vim.api.nvim_chan_send(vim.b.terminal_job_id, cmd .. "\r")
end

-- Command to build a project from a CMakeLists.txt from CMake configuration in STM32CubeMX
create_command("BuildProject", function(opts)
  local system = jit.os

  -- If clean is given clean the build folder
  if opts.args == "clean" then
    print "🧹 Cleaning the build folder..."
    vim.system({ "rm", "-r", "build" }):wait()
    print "✅ Build folder cleaned!"
  end

  -- Ensure build folder exists
  if vim.fn.isdirectory "build" == 0 then
    vim.fn.mkdir("build", "p")
  end

  -- Choose cmake binary depending on system
  local cmake = (system == "Windows") and "cmake" or "/mnt/c/ST/STM32CubeCLT_1.16.0/CMake/bin/cmake.exe"

  -- Define the CMake configure and build commands
  local configure_cmd = string.format(
    "%s -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_TOOLCHAIN_FILE='cmake/gcc-arm-none-eabi.cmake' -S . -B build/Debug -G Ninja",
    cmake
  )
  local build_cmd = string.format("%s --build build/Debug", cmake)

  -- Create a different final command depending on the OS.
  local full_cmd
  if system == "Windows" then
    -- Windows uses 'pause' to wait for user input.
    full_cmd = string.format("%s; %s; echo 'Build finished.'; pause", configure_cmd, build_cmd)
  else
    -- Linux/WSL uses 'read'.
    full_cmd =
      string.format('%s && %s && echo "Build finished. Press Enter to close." && read', configure_cmd, build_cmd)
  end

  print "🚀 Starting build in a new terminal..."
  -- Run the chained command in our helper function
  run_in_terminal(full_cmd)
end, {
  bang = false,
  desc = "Build a project from CMakeLists.txt on Windows or WSL",
  nargs = "?",
  complete = function()
    return { "clean" }
  end,
})

-- Command to flash the project
create_command("FlashProject", function()
  local system = jit.os
  local stm32_cli = (system == "Windows") and "STM32_Programmer_CLI"
    or "/mnt/c/ST/STM32CubeCLT_1.16.0/STM32CubeProgrammer/bin/STM32_Programmer_CLI.exe"

  -- The ELF file to flash is typically in build/Debug/ and has the same name as the project folder.
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  local elf_file = string.format("build/Debug/%s.elf", project_name)

  local args = {
    "--connect",
    "port=swd",
    "--download",
    elf_file, -- Use the full path to the ELF file
    "-hardRst",
    "-rst",
    "--start",
  }

  -- Combine the executable and its arguments into a single command string
  local flash_cmd = string.format("%s %s", stm32_cli, table.concat(args, " "))

  -- Create a different final command depending on the OS.
  local full_cmd
  if system == "Windows" then
    -- Windows uses 'pause' to wait for user input.
    full_cmd = string.format('%s; echo "Flashing finished. Press Enter to close."; pause', flash_cmd)
  else
    -- Linux/WSL uses 'read'.
    full_cmd = string.format('%s && echo "Flashing finished. Press Enter to close." && read', flash_cmd)
  end

  print "⚡ Starting flashing process in new terminal..."
  run_in_terminal(full_cmd)
end, {
  bang = false,
  desc = "Flash the current project",
  nargs = 0,
})
