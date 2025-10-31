-- Arduino Library Manager using Telescope
-- Provides interactive library search, installation, and management

local M = {}

-- Check if Telescope is available
local has_telescope, telescope = pcall(require, 'telescope')
if not has_telescope then
  vim.notify("Telescope not found. Library manager requires Telescope.", vim.log.levels.ERROR)
  return M
end

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local previewers = require('telescope.previewers')
local entry_display = require('telescope.pickers.entry_display')

-- Utility function to execute arduino-cli and get JSON output
local function exec_arduino_cli(cmd)
  local handle = io.popen(cmd .. " 2>&1")
  if not handle then
    return nil, "Failed to execute command"
  end

  local result = handle:read("*a")
  local success = handle:close()

  if not success then
    return nil, "Command failed: " .. result
  end

  return result
end

-- Get library search results
local function get_library_search_results(query)
  local cmd = string.format("arduino-cli lib search --format json '%s'", query)
  local output = exec_arduino_cli(cmd)

  if not output then
    return {}
  end

  local ok, data = pcall(vim.fn.json_decode, output)
  if not ok or not data or not data.libraries then
    return {}
  end

  return data.libraries or {}
end

-- Get installed libraries
local function get_installed_libraries()
  local cmd = "arduino-cli lib list --format json"
  local output = exec_arduino_cli(cmd)

  if not output then
    return {}
  end

  local ok, data = pcall(vim.fn.json_decode, output)
  if not ok or not data or not data.installed_libraries then
    return {}
  end

  return data.installed_libraries or {}
end

-- Get library dependencies
local function get_library_dependencies(lib_name)
  local cmd = string.format("arduino-cli lib deps --format json '%s'", lib_name)
  local output = exec_arduino_cli(cmd)

  if not output then
    return {}
  end

  local ok, data = pcall(vim.fn.json_decode, output)
  if not ok or not data or not data.dependencies then
    return {}
  end

  return data.dependencies or {}
end

-- Install a library
local function install_library(lib_name)
  vim.notify("Installing library: " .. lib_name, vim.log.levels.INFO)

  vim.schedule(function()
    local Terminal = require('toggleterm.terminal').Terminal
    local cmd = string.format("arduino-cli lib install '%s'", lib_name)

    local term = Terminal:new({
      cmd = cmd,
      close_on_exit = false,
      direction = 'float',
      float_opts = { border = 'curved' },
      on_open = function(t)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(t.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
      end,
    })
    term:toggle()
  end)
end

-- Uninstall a library
local function uninstall_library(lib_name)
  vim.ui.input(
    { prompt = string.format("Uninstall '%s'? (y/N): ", lib_name) },
    function(input)
      if input and input:lower() == 'y' then
        vim.notify("Uninstalling library: " .. lib_name, vim.log.levels.INFO)

        vim.schedule(function()
          local Terminal = require('toggleterm.terminal').Terminal
          local cmd = string.format("arduino-cli lib uninstall '%s'", lib_name)

          local term = Terminal:new({
            cmd = cmd,
            close_on_exit = false,
            direction = 'float',
            float_opts = { border = 'curved' },
            on_open = function(t)
              vim.cmd("startinsert!")
              vim.api.nvim_buf_set_keymap(t.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
            end,
          })
          term:toggle()
        end)
      end
    end
  )
end

-- Update a library
local function update_library(lib_name)
  vim.notify("Updating library: " .. lib_name, vim.log.levels.INFO)

  vim.schedule(function()
    local Terminal = require('toggleterm.terminal').Terminal
    local cmd = string.format("arduino-cli lib upgrade '%s'", lib_name)

    local term = Terminal:new({
      cmd = cmd,
      close_on_exit = false,
      direction = 'float',
      float_opts = { border = 'curved' },
      on_open = function(t)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(t.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
      end,
    })
    term:toggle()
  end)
end

-- Search Libraries Picker
function M.search_libraries()
  vim.ui.input({ prompt = "Search libraries: " }, function(query)
    if not query or query == "" then
      return
    end

    vim.notify("Searching for: " .. query, vim.log.levels.INFO)

    -- Get search results
    local libraries = get_library_search_results(query)

    if #libraries == 0 then
      vim.notify("No libraries found for: " .. query, vim.log.levels.WARN)
      return
    end

    -- Create entry display
    local displayer = entry_display.create({
      separator = ' ▏',
      items = {
        { width = 30 },      -- Library name
        { width = 10 },      -- Version
        { remaining = true }, -- Description
      },
    })

    local make_display = function(entry)
      return displayer({
        entry.name,
        entry.version,
        entry.sentence or "",
      })
    end

    -- Create picker
    pickers.new({}, {
      prompt_title = "Arduino Library Search: " .. query,
      finder = finders.new_table({
        results = libraries,
        entry_maker = function(lib)
          local latest = lib.latest or {}
          return {
            value = lib,
            name = lib.name,
            version = latest.version or "unknown",
            sentence = latest.sentence or "",
            paragraph = latest.paragraph or "",
            author = latest.author or "",
            maintainer = latest.maintainer or "",
            website = latest.website or "",
            category = latest.category or "",
            architectures = latest.architectures or {},
            ordinal = lib.name .. " " .. (latest.sentence or ""),
            display = make_display,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      previewer = previewers.new_buffer_previewer({
        title = "Library Details",
        define_preview = function(self, entry)
          local lines = {
            "📚 " .. entry.name,
            "═══════════════════════════════════════",
            "",
            "Version: " .. entry.version,
            "Author: " .. entry.author,
            "Maintainer: " .. entry.maintainer,
            "Category: " .. entry.category,
            "",
            "Description:",
            "  " .. entry.sentence,
            "",
          }

          if entry.paragraph ~= "" and entry.paragraph ~= entry.sentence then
            table.insert(lines, "Details:")
            table.insert(lines, "  " .. entry.paragraph)
            table.insert(lines, "")
          end

          if entry.website ~= "" then
            table.insert(lines, "Website: " .. entry.website)
            table.insert(lines, "")
          end

          if #entry.architectures > 0 then
            table.insert(lines, "Architectures: " .. table.concat(entry.architectures, ", "))
            table.insert(lines, "")
          end

          -- Get dependencies
          local deps = get_library_dependencies(entry.name)
          if #deps > 0 then
            table.insert(lines, "Dependencies:")
            for _, dep in ipairs(deps) do
              table.insert(lines, "  • " .. dep.name .. " (v" .. (dep.version_required or "any") .. ")")
            end
          else
            table.insert(lines, "Dependencies: None")
          end

          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        end,
      }),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          install_library(selection.name)
        end)

        return true
      end,
    }):find()
  end)
end

-- Installed Libraries Picker
function M.show_installed_libraries()
  vim.notify("Loading installed libraries...", vim.log.levels.INFO)

  -- Get installed libraries
  local libraries = get_installed_libraries()

  if #libraries == 0 then
    vim.notify("No libraries installed", vim.log.levels.WARN)
    return
  end

  -- Create entry display
  local displayer = entry_display.create({
    separator = ' ▏',
    items = {
      { width = 30 },      -- Library name
      { width = 10 },      -- Version
      { remaining = true }, -- Category
    },
  })

  local make_display = function(entry)
    return displayer({
      entry.name,
      entry.version,
      entry.category or "",
    })
  end

  -- Create picker
  pickers.new({}, {
    prompt_title = "Installed Arduino Libraries (" .. #libraries .. ")",
    finder = finders.new_table({
      results = libraries,
      entry_maker = function(item)
        local lib = item.library
        return {
          value = lib,
          name = lib.name,
          version = lib.version or "unknown",
          category = lib.category or "",
          sentence = lib.sentence or "",
          paragraph = lib.paragraph or "",
          author = lib.author or "",
          maintainer = lib.maintainer or "",
          website = lib.website or "",
          install_dir = lib.install_dir or "",
          license = lib.license or "",
          location = lib.location or "",
          ordinal = lib.name .. " " .. (lib.sentence or ""),
          display = make_display,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = "Library Details",
      define_preview = function(self, entry)
        local lines = {
          "📦 " .. entry.name .. " (Installed)",
          "═══════════════════════════════════════",
          "",
          "Version: " .. entry.version,
          "Author: " .. entry.author,
          "Maintainer: " .. entry.maintainer,
          "Category: " .. entry.category,
          "License: " .. entry.license,
          "Location: " .. entry.location,
          "",
          "Description:",
          "  " .. entry.sentence,
          "",
        }

        if entry.paragraph ~= "" and entry.paragraph ~= entry.sentence then
          table.insert(lines, "Details:")
          table.insert(lines, "  " .. entry.paragraph)
          table.insert(lines, "")
        end

        if entry.website ~= "" then
          table.insert(lines, "Website: " .. entry.website)
          table.insert(lines, "")
        end

        if entry.install_dir ~= "" then
          table.insert(lines, "Install Directory:")
          table.insert(lines, "  " .. entry.install_dir)
          table.insert(lines, "")
        end

        table.insert(lines, "Actions:")
        table.insert(lines, "  <Enter> - Uninstall library")
        table.insert(lines, "  <C-u>   - Update library")

        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
      end,
    }),
    attach_mappings = function(prompt_bufnr, map)
      -- Default action: uninstall
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        uninstall_library(selection.name)
      end)

      -- Ctrl-u: update library
      map('i', '<C-u>', function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        update_library(selection.name)
      end)

      map('n', '<C-u>', function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        update_library(selection.name)
      end)

      return true
    end,
  }):find()
end

-- Update all libraries
function M.update_all_libraries()
  vim.notify("Updating all libraries...", vim.log.levels.INFO)

  vim.schedule(function()
    local Terminal = require('toggleterm.terminal').Terminal
    local cmd = "arduino-cli lib upgrade"

    local term = Terminal:new({
      cmd = cmd,
      close_on_exit = false,
      direction = 'float',
      float_opts = { border = 'curved' },
      on_open = function(t)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(t.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
      end,
    })
    term:toggle()
  end)
end

-- Help/Info function
function M.show_help()
  local lines = {
    "Arduino Library Manager - Help",
    "═══════════════════════════════════════",
    "",
    "Keybindings:",
    "  <leader>als - Search libraries",
    "  <leader>ali - View installed libraries",
    "  <leader>alu - Update all libraries",
    "  <leader>alh - Show this help",
    "",
    "Search Results:",
    "  <Enter>  - Install selected library",
    "  <Esc>    - Close picker",
    "",
    "Installed Libraries:",
    "  <Enter>  - Uninstall selected library",
    "  <C-u>    - Update selected library",
    "  <Esc>    - Close picker",
    "",
    "Tips:",
    "  • Use fuzzy search to find libraries quickly",
    "  • Preview pane shows library details and dependencies",
    "  • All operations open in a floating terminal",
    "  • Press 'q' in terminal to close it",
  }

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')

  local width = 60
  local height = #lines + 2
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = 'minimal',
    border = 'rounded',
  })

  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>close<CR>', { noremap = true, silent = true })
end

return M
