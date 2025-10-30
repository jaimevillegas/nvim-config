-- Arduino CLI wrapper module for Neovim
-- Provides integration with arduino-cli for native Arduino development

local M = {}

-- Check if arduino-cli is installed
local function check_arduino_cli()
  local handle = io.popen("which arduino-cli 2>/dev/null")
  local result = handle:read("*a")
  handle:close()
  return result ~= ""
end

-- Execute arduino-cli command in a terminal
local function exec_in_term(cmd, name)
  name = name or "Arduino CLI"

  -- Use vim.schedule to ensure we're in a safe context
  vim.schedule(function()
    -- Try to use toggleterm if available
    local ok, toggleterm = pcall(require, 'toggleterm.terminal')

    if ok and toggleterm and toggleterm.Terminal then
      local Terminal = toggleterm.Terminal
      local term = Terminal:new({
        cmd = cmd,
        close_on_exit = false,
        direction = 'float',
        hidden = false,
        float_opts = {
          border = 'curved',
        },
        on_open = function(t)
          vim.cmd("startinsert!")
          -- Add keybinding to close with 'q' in normal mode
          vim.api.nvim_buf_set_keymap(t.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
        end,
        on_close = function()
          vim.cmd("checktime")
        end,
      })
      term:toggle()
    else
      -- Fallback to built-in terminal
      vim.cmd('botright split')
      vim.cmd('resize 15')
      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_win_set_buf(0, bufnr)
      vim.fn.termopen(cmd, {
        on_exit = function(job_id, exit_code, event_type)
          if exit_code == 0 then
            vim.notify("Command completed successfully", vim.log.levels.INFO)
          else
            vim.notify("Command failed with code: " .. exit_code, vim.log.levels.ERROR)
          end
        end
      })
      vim.cmd('startinsert')
    end
  end)
end

-- Get current file directory and sketch name
local function get_sketch_info()
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.expand("%:p:h")
  local sketch_name = vim.fn.expand("%:t:r")

  -- If we're in a .ino file, the sketch is the directory name
  if vim.fn.expand("%:e") == "ino" then
    sketch_name = vim.fn.fnamemodify(dir, ":t")
  end

  return {
    file = file,
    dir = dir,
    name = sketch_name
  }
end

-- Compile/Verify sketch
function M.compile()
  if not check_arduino_cli() then
    vim.notify("arduino-cli not found. Please install it first.", vim.log.levels.ERROR)
    return
  end

  local sketch = get_sketch_info()
  -- Add --verbose flag to show detailed build information like Arduino IDE
  local cmd = string.format("arduino-cli compile --fqbn %s --verbose '%s'",
    vim.g.arduino_board or "esp32:esp32:esp32",
    sketch.dir)

  exec_in_term(cmd, "Arduino Compile")
end

-- Verify sketch (same as compile)
M.verify = M.compile

-- Upload sketch to board
function M.upload()
  if not check_arduino_cli() then
    vim.notify("arduino-cli not found. Please install it first.", vim.log.levels.ERROR)
    return
  end

  local sketch = get_sketch_info()
  local board = vim.g.arduino_board or "esp32:esp32:esp32"
  local port = vim.g.arduino_port or "/dev/ttyUSB0"

  -- Add --verbose flag to show detailed upload information
  local cmd = string.format("arduino-cli upload --fqbn %s --port %s --verbose '%s'",
    board, port, sketch.dir)

  exec_in_term(cmd, "Arduino Upload")
end

-- Compile and upload
function M.compile_and_upload()
  if not check_arduino_cli() then
    vim.notify("arduino-cli not found. Please install it first.", vim.log.levels.ERROR)
    return
  end

  local sketch = get_sketch_info()
  local board = vim.g.arduino_board or "esp32:esp32:esp32"
  local port = vim.g.arduino_port or "/dev/ttyUSB0"

  -- Add --verbose flags to show detailed information for both compile and upload
  local cmd = string.format("arduino-cli compile --fqbn %s --verbose '%s' && arduino-cli upload --fqbn %s --port %s --verbose '%s'",
    board, sketch.dir, board, port, sketch.dir)

  exec_in_term(cmd, "Arduino Build & Upload")
end

-- List available boards
function M.list_boards()
  if not check_arduino_cli() then
    vim.notify("arduino-cli not found. Please install it first.", vim.log.levels.ERROR)
    return
  end

  exec_in_term("arduino-cli board list", "Arduino Boards")
end

-- Select board interactively
function M.select_board()
  if not check_arduino_cli() then
    vim.notify("arduino-cli not found. Please install it first.", vim.log.levels.ERROR)
    return
  end

  -- Get list of installed boards
  local handle = io.popen("arduino-cli board listall --format json 2>/dev/null")
  local json_output = handle:read("*a")
  handle:close()

  -- Parse JSON and create selection list
  local ok, json = pcall(vim.fn.json_decode, json_output)
  if not ok or not json or not json.boards then
    vim.notify("Failed to get board list. Run :ArduinoInstallCore first", vim.log.levels.WARN)
    return
  end

  local boards = {}
  local board_fqbns = {}

  for _, board in ipairs(json.boards) do
    table.insert(boards, board.name)
    table.insert(board_fqbns, board.fqbn)
  end

  if #boards == 0 then
    vim.notify("No boards found. Install a core first.", vim.log.levels.WARN)
    return
  end

  vim.ui.select(boards, {
    prompt = "Select Arduino Board:",
  }, function(choice, idx)
    if choice then
      vim.g.arduino_board = board_fqbns[idx]
      vim.notify("Board set to: " .. choice .. " (" .. board_fqbns[idx] .. ")", vim.log.levels.INFO)
    end
  end)
end

-- Select port interactively
function M.select_port()
  if not check_arduino_cli() then
    vim.notify("arduino-cli not found. Please install it first.", vim.log.levels.ERROR)
    return
  end

  -- Get list of available ports
  local handle = io.popen("arduino-cli board list --format json 2>/dev/null")
  local json_output = handle:read("*a")
  handle:close()

  local ok, json = pcall(vim.fn.json_decode, json_output)
  if not ok or not json or not json.detected_ports then
    vim.notify("Failed to get port list", vim.log.levels.ERROR)
    return
  end

  local ports = {}
  local port_addresses = {}

  for _, port_info in ipairs(json.detected_ports) do
    if port_info.port and port_info.port.address then
      local label = port_info.port.address

      -- Add board name if detected
      if port_info.matching_boards and #port_info.matching_boards > 0 then
        label = label .. " (" .. port_info.matching_boards[1].name .. ")"
      elseif port_info.port.protocol_label then
        label = label .. " (" .. port_info.port.protocol_label .. ")"
      end

      table.insert(ports, label)
      table.insert(port_addresses, port_info.port.address)
    end
  end

  if #ports == 0 then
    vim.notify("No ports found. Is your Arduino connected?", vim.log.levels.WARN)
    return
  end

  vim.ui.select(ports, {
    prompt = "Select Port:",
  }, function(choice, idx)
    if choice then
      vim.g.arduino_port = port_addresses[idx]
      vim.notify("Port set to: " .. port_addresses[idx], vim.log.levels.INFO)
    end
  end)
end

-- Select baudrate interactively
function M.select_baudrate()
  local common_baudrates = {
    "300",
    "1200",
    "2400",
    "4800",
    "9600",
    "19200",
    "38400",
    "57600",
    "74880",
    "115200",
    "230400",
    "250000",
    "500000",
    "1000000",
    "2000000"
  }

  local current = vim.g.arduino_baudrate or "9600"
  local prompt_text = string.format("Select Baudrate (current: %s):", current)

  vim.ui.select(common_baudrates, {
    prompt = prompt_text,
  }, function(choice)
    if choice then
      vim.g.arduino_baudrate = choice
      vim.notify("Baudrate set to: " .. choice, vim.log.levels.INFO)
    end
  end)
end

-- Open serial monitor
function M.serial_monitor()
  if not check_arduino_cli() then
    vim.notify("arduino-cli not found. Please install it first.", vim.log.levels.ERROR)
    return
  end

  local port = vim.g.arduino_port or "/dev/ttyUSB0"
  local baudrate = vim.g.arduino_baudrate or "9600"

  local cmd = string.format("arduino-cli monitor --port %s --config baudrate=%s", port, baudrate)
  exec_in_term(cmd, "Arduino Serial Monitor")
end

-- Library management
function M.search_library()
  if not check_arduino_cli() then
    vim.notify("arduino-cli not found. Please install it first.", vim.log.levels.ERROR)
    return
  end

  vim.ui.input({ prompt = "Search library: " }, function(input)
    if input and input ~= "" then
      local cmd = string.format("arduino-cli lib search '%s'", input)
      exec_in_term(cmd, "Arduino Library Search")
    end
  end)
end

function M.install_library()
  if not check_arduino_cli() then
    vim.notify("arduino-cli not found. Please install it first.", vim.log.levels.ERROR)
    return
  end

  vim.ui.input({ prompt = "Install library: " }, function(input)
    if input and input ~= "" then
      local cmd = string.format("arduino-cli lib install '%s'", input)
      exec_in_term(cmd, "Arduino Library Install")
    end
  end)
end

function M.list_libraries()
  if not check_arduino_cli() then
    vim.notify("arduino-cli not found. Please install it first.", vim.log.levels.ERROR)
    return
  end

  exec_in_term("arduino-cli lib list", "Arduino Libraries")
end

function M.update_libraries()
  if not check_arduino_cli() then
    vim.notify("arduino-cli not found. Please install it first.", vim.log.levels.ERROR)
    return
  end

  exec_in_term("arduino-cli lib upgrade", "Arduino Library Update")
end

-- Core management
function M.install_core()
  if not check_arduino_cli() then
    vim.notify("arduino-cli not found. Please install it first.", vim.log.levels.ERROR)
    return
  end

  vim.ui.input({ prompt = "Install core (e.g., arduino:avr): " }, function(input)
    if input and input ~= "" then
      local cmd = string.format("arduino-cli core install '%s'", input)
      exec_in_term(cmd, "Arduino Core Install")
    end
  end)
end

function M.update_cores()
  if not check_arduino_cli() then
    vim.notify("arduino-cli not found. Please install it first.", vim.log.levels.ERROR)
    return
  end

  exec_in_term("arduino-cli core upgrade", "Arduino Core Update")
end

function M.list_cores()
  if not check_arduino_cli() then
    vim.notify("arduino-cli not found. Please install it first.", vim.log.levels.ERROR)
    return
  end

  exec_in_term("arduino-cli core list", "Arduino Cores")
end

function M.update_index()
  if not check_arduino_cli() then
    vim.notify("arduino-cli not found. Please install it first.", vim.log.levels.ERROR)
    return
  end

  exec_in_term("arduino-cli core update-index", "Arduino Update Index")
end

-- Create new sketch
function M.new_sketch()
  if not check_arduino_cli() then
    vim.notify("arduino-cli not found. Please install it first.", vim.log.levels.ERROR)
    return
  end

  vim.ui.input({ prompt = "Sketch name: " }, function(input)
    if input and input ~= "" then
      local cmd = string.format("arduino-cli sketch new '%s'", input)
      exec_in_term(cmd, "Arduino New Sketch")
    end
  end)
end

-- Show current configuration
function M.show_config()
  local board = vim.g.arduino_board or "not set"
  local port = vim.g.arduino_port or "not set"
  local baudrate = vim.g.arduino_baudrate or "9600"

  local msg = string.format(
    "Arduino Configuration:\n" ..
    "  Board: %s\n" ..
    "  Port: %s\n" ..
    "  Baudrate: %s",
    board, port, baudrate
  )

  vim.notify(msg, vim.log.levels.INFO)
end

return M
