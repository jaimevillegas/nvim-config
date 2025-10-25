-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

map("n", "<leader>t", function()
  -- Get all available colorschemes
  local all_themes = vim.fn.getcompletion("", "color")

  -- Legacy themes to exclude
  local legacy_themes = {
    "blue", "darkblue", "default", "delek", "desert", "elflord",
    "evening", "habamax", "industry", "koehler", "lunaperche",
    "morning", "murphy", "pablo", "peachpuff", "quiet", "retrobox",
    "ron", "shine", "slate", "sorbet", "torte", "unokai", "vim",
    "wildcharm", "zaibatsu", "zellner"
  }

  -- Filter out legacy themes
  local themes = {}
  local legacy_set = {}
  for _, theme in ipairs(legacy_themes) do
    legacy_set[theme] = true
  end

  for _, theme in ipairs(all_themes) do
    if not legacy_set[theme] then
      table.insert(themes, theme)
    end
  end

  -- Add onedark variations
  local onedark_variations = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" }
  for _, variation in ipairs(onedark_variations) do
    table.insert(themes, "onedark (" .. variation .. ")")
  end

  -- Show a selection menu
  vim.ui.select(themes, { prompt = "Select a theme:" }, function(choice)
    if choice then
      -- Check if it's a onedark variation
      local onedark_match = choice:match("^onedark %((.+)%)$")
      if onedark_match then
        -- Setup onedark with the selected style
        pcall(require("onedark").setup, { style = onedark_match })
        pcall(require("onedark").load)
      else
        -- Apply the selected theme for other themes
        vim.cmd.colorscheme(choice)
      end

      -- Save the selected theme for persistence
      local theme_file = vim.fn.stdpath("config") .. "/current_theme"
      local file = io.open(theme_file, "w")
      if file then
        file:write(choice)
        file:close()
      end
    end
  end)
end, { desc = "Select theme" })
map("i", "jj", "<Esc>", { desc = "Exit insert mode with jj" })
map("i", "jj", "<Esc>", { desc = "Exit insert mode with jj" })
