-- Commands
local create_command = vim.api.nvim_create_user_command

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
  local on_exit = function(obj)
    vim.schedule(function()
      vim.notify(obj.stdout, vim.log.levels.INFO)
    end)
  end

  -- Run configure
  print "⚙️ Generating CMake configuration from CMakeLists.txt..."
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
    }, { text = true }, on_exit)
    :wait()
  print "✅ CMake configuration generated!"

  -- Run build
  print "🏗️ Building the project..."
  vim.system({ cmake, "--build", "build/Debug" }, { text = true }, on_exit):wait()
  print "🎉 Project build complete!"
end, {
  bang = false,
  desc = "Build a project from CMakeLists.txt on Windows or WSL",
  nargs = "?",
})

create_command("FlashProject", function()
  local system = jit.os
  local stm32_cli = (system == "Windows") and "STM32_Programmer_CLI"
    or "/mnt/c/ST/STM32CubeCLT_1.16.0/STM32CubeProgrammer/bin/STM32_Programmer_CLI.exe"
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

  local on_exit = function(obj)
    vim.schedule(function()
      vim.notify(obj.stdout, vim.log.levels.INFO)
    end)
  end

  -- Run STM32_Programmer_CLI
  print "⚡ Starting flashing process..."
  vim.system({ stm32_cli, unpack(args) }, {}, on_exit):wait()
  print "✅ Flashing complete! 🎉"
end, {})
