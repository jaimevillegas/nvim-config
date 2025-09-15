-- Plugin para sincronizar el tema de LazyVim con omarchy
-- Detecta automáticamente el tema activo de omarchy y aplica el equivalente en LazyVim

local M = {}

-- Mapeo de temas de omarchy a sus equivalentes en LazyVim
local theme_mapping = {
  ["catppuccin"] = {
    plugin = "catppuccin/nvim",
    name = "catppuccin-mocha",
    config_name = "catppuccin",
  },
  ["catppuccin-latte"] = {
    plugin = "catppuccin/nvim",
    name = "catppuccin-latte",
    config_name = "catppuccin",
  },
  ["everforest"] = {
    plugin = "sainnhe/everforest",
    name = "everforest",
    config_name = "everforest",
  },
  ["gruvbox"] = {
    plugin = "ellisonleao/gruvbox.nvim",
    name = "gruvbox",
    config_name = "gruvbox",
  },
  ["kanagawa"] = {
    plugin = "rebelot/kanagawa.nvim",
    name = "kanagawa-wave",
    config_name = "kanagawa",
  },
  ["matte-black"] = {
    plugin = "folke/tokyonight.nvim",
    name = "tokyonight-night",
    config_name = "tokyonight",
  },
  ["nord"] = {
    plugin = "shaunsingh/nord.nvim",
    name = "nord",
    config_name = "nord",
  },
  ["osaka-jade"] = {
    plugin = "folke/tokyonight.nvim",
    name = "tokyonight-storm",
    config_name = "tokyonight",
  },
  ["ristretto"] = {
    plugin = "sainnhe/gruvbox-material",
    name = "gruvbox-material",
    config_name = "gruvbox-material",
  },
  ["rose-pine"] = {
    plugin = "rose-pine/neovim",
    name = "rose-pine",
    config_name = "rose-pine",
  },
  ["tokyo-night"] = {
    plugin = "folke/tokyonight.nvim",
    name = "tokyonight-night",
    config_name = "tokyonight",
  },
}

-- Función para detectar el tema actual de omarchy
function M.get_current_omarchy_theme()
  -- Método 1: Leer directamente del archivo neovim.lua generado por omarchy
  local neovim_config_path = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")
  local file, err = io.open(neovim_config_path, "r")
  if file then
    local content, read_err = file:read("*a")
    file:close()

    if read_err then
      vim.notify("Error al leer el archivo de tema de omarchy: " .. tostring(read_err), vim.log.levels.WARN)
    elseif content then
      -- Buscar el colorscheme en el archivo
      local colorscheme = content:match('colorscheme = "([^"]+)"')
      if colorscheme then
        return colorscheme
      end
    end
  elseif err then
    -- No es un error, solo un log informativo si el archivo no existe
    vim.notify("Archivo de tema de omarchy no encontrado en " .. neovim_config_path .. ". Usando fallback.", vim.log.levels.INFO)
  end

  -- Método 2: Usar readlink como fallback (método original mejorado)
  local handle = io.popen("readlink ~/.config/omarchy/current/theme 2>/dev/null")
  if not handle then
    return nil
  end

  local result = handle:read("*a")
  handle:close()

  if result and result ~= "" then
    -- Extraer solo el nombre del tema del path y limpiar caracteres extra
    local theme_name = result:match("/([^/]+)$")
    if theme_name then
      -- Limpiar saltos de línea y espacios
      return theme_name:gsub("[%s%c]+", "")
    end
  end

  return nil
end

-- Función para aplicar el tema correspondiente
function M.apply_theme(theme_name)
  local theme_config = theme_mapping[theme_name]
  if not theme_config then
    vim.notify("Tema de omarchy '" .. theme_name .. "' no encontrado en mapeo de LazyVim", vim.log.levels.WARN)
    return false
  end

  -- Verificar si lazy está disponible
  local ok, lazy = pcall(require, "lazy")
  if not ok then
    vim.notify("Lazy.nvim no está disponible", vim.log.levels.WARN)
    return false
  end

  -- Verificar si el plugin está instalado
  local plugins_config = lazy.plugins()
  local plugin_installed = false
  for _, plugin in ipairs(plugins_config) do
    if plugin[1] == theme_config.plugin or plugin.name == theme_config.plugin then
      plugin_installed = true
      break
    end
  end

  if not plugin_installed then
    vim.notify("Plugin " .. theme_config.plugin .. " no está instalado", vim.log.levels.WARN)
    return false
  end

  -- Aplicar configuraciones específicas del tema antes de activarlo
  local config_ok = pcall(function()
    if theme_config.config_name == "catppuccin" then
      local catppuccin_ok, catppuccin = pcall(require, "catppuccin")
      if catppuccin_ok then
        catppuccin.setup({
          flavour = theme_name == "catppuccin-latte" and "latte" or "mocha",
          background = {
            light = "latte",
            dark = "mocha",
          },
          transparent_background = false,
          show_end_of_buffer = false,
          term_colors = true,
        })
      end
    elseif theme_config.config_name == "gruvbox" then
      vim.g.gruvbox_contrast_dark = "medium"
      vim.g.gruvbox_contrast_light = "medium"
      vim.g.gruvbox_transparent_bg = 0
    elseif theme_config.config_name == "everforest" then
      vim.g.everforest_background = "medium"
      vim.g.everforest_better_performance = 1
      vim.g.everforest_transparent_background = 0
    elseif theme_config.config_name == "kanagawa" then
      local kanagawa_ok, kanagawa = pcall(require, "kanagawa")
      if kanagawa_ok then
        kanagawa.setup({
          compile = false,
          undercurl = true,
          commentStyle = { italic = true },
          functionStyle = {},
          keywordStyle = { italic = true },
          statementStyle = { bold = true },
          typeStyle = {},
          transparent = false,
          dimInactive = false,
          terminalColors = true,
        })
      end
    elseif theme_config.config_name == "rose-pine" then
      local rosepine_ok, rosepine = pcall(require, "rose-pine")
      if rosepine_ok then
        rosepine.setup({
          variant = "auto",
          dark_variant = "main",
          bold_vert_split = false,
          dim_nc_background = false,
          disable_background = false,
          disable_float_background = false,
        })
      end
    elseif theme_config.config_name == "tokyonight" then
      local tokyonight_ok, tokyonight = pcall(require, "tokyonight")
      if tokyonight_ok then
        tokyonight.setup({
          style = theme_name == "tokyo-night" and "night" or "storm",
          light_style = "day",
          transparent = false,
          terminal_colors = true,
          styles = {
            comments = { italic = true },
            keywords = { italic = true },
            functions = {},
            variables = {},
          },
        })
      end
    end
  end)

  if not config_ok then
    vim.notify("Error configurando tema " .. theme_config.config_name, vim.log.levels.WARN)
  end

  -- Aplicar el colorscheme
  pcall(function()
    vim.cmd.colorscheme(theme_config.name)
  end)

  return true
end

-- Función principal para sincronizar
function M.sync_with_omarchy()
  local ok, current_theme = pcall(M.get_current_omarchy_theme)
  if not ok then
    vim.notify("Error al detectar el tema de omarchy: " .. tostring(current_theme), vim.log.levels.ERROR)
    return
  end

  if current_theme then
    M.apply_theme(current_theme)
  else
    vim.notify("No se pudo detectar el tema actual de omarchy", vim.log.levels.WARN)
  end
end

-- Auto comando para detectar cambios en el tema
function M.setup_auto_sync()
  local group = vim.api.nvim_create_augroup("OmarchyThemeSync", { clear = true })

  -- Sincronizar al iniciar nvim
  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    callback = function()
      vim.defer_fn(M.sync_with_omarchy, 100)
    end,
  })

  -- Opcional: Sincronizar cuando se enfoque la ventana (por si cambió el tema mientras nvim estaba en background)
  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = function()
      M.sync_with_omarchy()
    end,
  })
end

-- Comando manual para forzar sincronización
vim.api.nvim_create_user_command("OmarchySync", function()
  M.sync_with_omarchy()
end, { desc = "Sincronizar tema con omarchy" })

-- Comando de diagnóstico
vim.api.nvim_create_user_command("OmarchyDiagnostic", function()
  print("=== Diagnóstico Omarchy Theme Sync ===")

  -- Mostrar tema actual de omarchy
  local current_theme = M.get_current_omarchy_theme()
  if current_theme then
    print("Tema actual de omarchy: " .. current_theme)

    -- Verificar si hay mapeo para este tema
    local theme_config = theme_mapping[current_theme]
    if theme_config then
      print("Mapeo encontrado: " .. theme_config.plugin .. " -> " .. theme_config.name)

      -- Verificar si el plugin está instalado
      local ok, lazy = pcall(require, "lazy")
      if ok then
        local plugins_config = lazy.plugins()
        local plugin_installed = false
        for _, plugin in ipairs(plugins_config) do
          if plugin[1] == theme_config.plugin or plugin.name == theme_config.plugin then
            plugin_installed = true
            break
          end
        end

        if plugin_installed then
          print("Plugin instalado: ✓")
        else
          print("Plugin NO instalado: ✗")
        end
      else
        print("Lazy.nvim no disponible: ✗")
      end
    else
      print("No hay mapeo para el tema: " .. current_theme)
    end
  else
    print("No se pudo detectar el tema de omarchy")
  end

  -- Mostrar tema actual de nvim
  if vim.g.colors_name then
    print("Tema actual de nvim: " .. vim.g.colors_name)
  else
    print("No hay tema aplicado en nvim")
  end

  -- Listar temas disponibles
  print("\nTemas disponibles en mapeo:")
  for theme, config in pairs(theme_mapping) do
    print("  " .. theme .. " -> " .. config.name)
  end

  print("\n=== Fin del diagnóstico ===")
end, { desc = "Diagnóstico del sistema de temas omarchy" })

return {
  -- Todos los plugins de temas necesarios
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
  },
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    lazy = false,
  },
  {
    "sainnhe/everforest",
    priority = 1000,
    lazy = false,
  },
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    lazy = false,
  },
  {
    "shaunsingh/nord.nvim",
    priority = 1000,
    lazy = false,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    lazy = false,
  },
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    lazy = false,
  },
  {
    "sainnhe/gruvbox-material",
    priority = 1000,
    lazy = false,
  },

  -- Configuración para LazyVim
  {
    "LazyVim/LazyVim",
    opts = function()
      -- Configurar el tema inicial
      M.setup_auto_sync()

      -- Detectar tema actual y aplicarlo
      local current_theme = M.get_current_omarchy_theme()
      local colorscheme = "tokyonight" -- fallback por defecto

      if current_theme and theme_mapping[current_theme] then
        colorscheme = theme_mapping[current_theme].name
      end

      return {
        colorscheme = colorscheme,
      }
    end,
  },
}
