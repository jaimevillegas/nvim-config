-- Unified Arduino/PlatformIO keybindings
-- Detects project type and provides appropriate commands under <leader>a

local M = {}

-- Detect project type
local function is_platformio_project()
  local platformio_ini = vim.fn.findfile("platformio.ini", vim.fn.getcwd() .. ";")
  return platformio_ini ~= ""
end

local function is_arduino_project()
  local ino_files = vim.fn.glob(vim.fn.getcwd() .. "/**/*.ino", false, true)
  return #ino_files > 0
end

-- Setup keybindings
function M.setup()
  local arduino_cli = require("arduino-cli")

  -- Check which-key availability for better menu display
  local has_which_key, which_key = pcall(require, "which-key")

  -- Main Arduino/PlatformIO menu prefix
  local keymap_opts = { noremap = true, silent = true }

  -- Common operations (smart detection)
  vim.keymap.set("n", "<leader>ab", function()
    if is_platformio_project() then
      vim.cmd("Piorun build")
    else
      arduino_cli.compile()
    end
  end, vim.tbl_extend("force", keymap_opts, { desc = "Build/Compile" }))

  vim.keymap.set("n", "<leader>au", function()
    if is_platformio_project() then
      vim.cmd("Piorun upload")
    else
      arduino_cli.upload()
    end
  end, vim.tbl_extend("force", keymap_opts, { desc = "Upload" }))

  vim.keymap.set("n", "<leader>am", function()
    if is_platformio_project() then
      vim.cmd("Piomon")
    else
      arduino_cli.serial_monitor()
    end
  end, vim.tbl_extend("force", keymap_opts, { desc = "Serial Monitor" }))

  vim.keymap.set("n", "<leader>ac", function()
    if is_platformio_project() then
      vim.cmd("Piorun clean")
    else
      arduino_cli.compile()
    end
  end, vim.tbl_extend("force", keymap_opts, { desc = "Clean/Compile" }))

  vim.keymap.set("n", "<leader>av", function()
    arduino_cli.verify()
  end, vim.tbl_extend("force", keymap_opts, { desc = "Verify" }))

  -- Arduino CLI specific commands
  vim.keymap.set("n", "<leader>aB", arduino_cli.select_board,
    vim.tbl_extend("force", keymap_opts, { desc = "Select Board" }))

  vim.keymap.set("n", "<leader>aP", arduino_cli.select_port,
    vim.tbl_extend("force", keymap_opts, { desc = "Select Port" }))

  vim.keymap.set("n", "<leader>aS", arduino_cli.select_baudrate,
    vim.tbl_extend("force", keymap_opts, { desc = "Select Baudrate" }))

  vim.keymap.set("n", "<leader>aD", arduino_cli.list_boards,
    vim.tbl_extend("force", keymap_opts, { desc = "List Devices/Boards" }))

  vim.keymap.set("n", "<leader>aU", arduino_cli.compile_and_upload,
    vim.tbl_extend("force", keymap_opts, { desc = "Build & Upload" }))

  vim.keymap.set("n", "<leader>ai", arduino_cli.show_config,
    vim.tbl_extend("force", keymap_opts, { desc = "Show Arduino Config" }))

  -- Library management submenu (<leader>al) - Using Telescope
  local lib_manager = require("arduino-cli.library-manager")

  vim.keymap.set("n", "<leader>als", lib_manager.search_libraries,
    vim.tbl_extend("force", keymap_opts, { desc = "Search Libraries (Telescope)" }))

  vim.keymap.set("n", "<leader>ali", lib_manager.show_installed_libraries,
    vim.tbl_extend("force", keymap_opts, { desc = "Installed Libraries (Telescope)" }))

  vim.keymap.set("n", "<leader>alu", lib_manager.update_all_libraries,
    vim.tbl_extend("force", keymap_opts, { desc = "Update All Libraries" }))

  vim.keymap.set("n", "<leader>alh", lib_manager.show_help,
    vim.tbl_extend("force", keymap_opts, { desc = "Library Manager Help" }))

  -- Core management submenu (<leader>aC)
  vim.keymap.set("n", "<leader>aCi", arduino_cli.install_core,
    vim.tbl_extend("force", keymap_opts, { desc = "Install Core" }))

  vim.keymap.set("n", "<leader>aCu", arduino_cli.update_cores,
    vim.tbl_extend("force", keymap_opts, { desc = "Update Cores" }))

  vim.keymap.set("n", "<leader>aCl", arduino_cli.list_cores,
    vim.tbl_extend("force", keymap_opts, { desc = "List Cores" }))

  vim.keymap.set("n", "<leader>aCU", arduino_cli.update_index,
    vim.tbl_extend("force", keymap_opts, { desc = "Update Index" }))

  -- Sketch operations
  vim.keymap.set("n", "<leader>asn", arduino_cli.new_sketch,
    vim.tbl_extend("force", keymap_opts, { desc = "New Sketch" }))

  -- PlatformIO specific commands (accessible directly)
  vim.keymap.set("n", "<leader>api", "<cmd>Pioinit<cr>",
    vim.tbl_extend("force", keymap_opts, { desc = "PlatformIO Init" }))

  vim.keymap.set("n", "<leader>apb", "<cmd>Piorun build<cr>",
    vim.tbl_extend("force", keymap_opts, { desc = "PlatformIO Build" }))

  vim.keymap.set("n", "<leader>apu", "<cmd>Piorun upload<cr>",
    vim.tbl_extend("force", keymap_opts, { desc = "PlatformIO Upload" }))

  vim.keymap.set("n", "<leader>apm", "<cmd>Piomon<cr>",
    vim.tbl_extend("force", keymap_opts, { desc = "PlatformIO Monitor" }))

  vim.keymap.set("n", "<leader>apd", "<cmd>Piodebug<cr>",
    vim.tbl_extend("force", keymap_opts, { desc = "PlatformIO Debug" }))

  vim.keymap.set("n", "<leader>apc", "<cmd>Piorun clean<cr>",
    vim.tbl_extend("force", keymap_opts, { desc = "PlatformIO Clean" }))

  vim.keymap.set("n", "<leader>apt", "<cmd>Piorun test<cr>",
    vim.tbl_extend("force", keymap_opts, { desc = "PlatformIO Test" }))

  vim.keymap.set("n", "<leader>apl", "<cmd>Piolib<cr>",
    vim.tbl_extend("force", keymap_opts, { desc = "PlatformIO Libraries" }))

  -- PlatformIO helper commands
  vim.keymap.set("n", "<leader>aph", "<cmd>Piocmdh<cr>",
    vim.tbl_extend("force", keymap_opts, { desc = "PlatformIO Help" }))

  vim.keymap.set("n", "<leader>apf", "<cmd>Piocmdf<cr>",
    vim.tbl_extend("force", keymap_opts, { desc = "PlatformIO Full Menu" }))

  -- Register which-key groups if available (new format)
  if has_which_key then
    which_key.add({
      { "<leader>a", group = "Arduino/PlatformIO" },
      { "<leader>ab", desc = "Build/Compile" },
      { "<leader>au", desc = "Upload" },
      { "<leader>am", desc = "Serial Monitor" },
      { "<leader>ac", desc = "Clean/Compile" },
      { "<leader>av", desc = "Verify" },
      { "<leader>aB", desc = "Select Board" },
      { "<leader>aP", desc = "Select Port" },
      { "<leader>aS", desc = "Select Baudrate" },
      { "<leader>aD", desc = "List Devices" },
      { "<leader>aU", desc = "Build & Upload" },
      { "<leader>ai", desc = "Show Config" },

      { "<leader>al", group = "Libraries" },
      { "<leader>als", desc = "Search (Telescope)" },
      { "<leader>ali", desc = "Installed (Telescope)" },
      { "<leader>alu", desc = "Update All" },
      { "<leader>alh", desc = "Help" },

      { "<leader>aC", group = "Cores" },
      { "<leader>aCi", desc = "Install" },
      { "<leader>aCu", desc = "Update" },
      { "<leader>aCl", desc = "List" },
      { "<leader>aCU", desc = "Update Index" },

      { "<leader>as", group = "Sketch" },
      { "<leader>asn", desc = "New Sketch" },

      { "<leader>ap", group = "PlatformIO" },
      { "<leader>api", desc = "Init" },
      { "<leader>apb", desc = "Build" },
      { "<leader>apu", desc = "Upload" },
      { "<leader>apm", desc = "Monitor" },
      { "<leader>apd", desc = "Debug" },
      { "<leader>apc", desc = "Clean" },
      { "<leader>apt", desc = "Test" },
      { "<leader>apl", desc = "Libraries" },
      { "<leader>aph", desc = "Help" },
      { "<leader>apf", desc = "Full Menu" },
    })
  end

  -- Auto-detect and notify project type
  vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
    pattern = {"*.ino", "*.cpp", "*.c", "*.h"},
    callback = function()
      if is_platformio_project() then
        vim.b.project_type = "platformio"
      elseif is_arduino_project() then
        vim.b.project_type = "arduino"
      end
    end,
  })

  -- Set default board and port if not set
  if not vim.g.arduino_board then
    vim.g.arduino_board = "esp32:esp32:esp32"  -- ESP32 Dev Module (generic)
  end
  if not vim.g.arduino_port then
    vim.g.arduino_port = "/dev/ttyUSB0"
  end
  if not vim.g.arduino_baudrate then
    vim.g.arduino_baudrate = "9600"
  end
end

-- Call setup on module load
M.setup()

return M
