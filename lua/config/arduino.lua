-- Configuración específica para Arduino
local M = {}

-- Función para detectar proyectos Arduino
function M.is_arduino_project()
  local indicators = {
    "platformio.ini",
    "*.ino",
    "lib/",
    "src/main.cpp",
  }
  
  for _, pattern in ipairs(indicators) do
    if vim.fn.glob(pattern) ~= "" then
      return true
    end
  end
  return false
end

-- Configurar resaltado mejorado para Arduino
function M.setup()
  -- Autocomandos para archivos Arduino
  local arduino_group = vim.api.nvim_create_augroup("ArduinoConfig", { clear = true })
  
  -- Detectar archivos .ino como Arduino
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = arduino_group,
    pattern = "*.ino",
    callback = function()
      vim.bo.filetype = "arduino"
      -- Configurar highlighting específico
      vim.cmd([[
        syntax match arduinoFunction "\<\(setup\|loop\)\>"
        syntax match arduinoConstant "\<\(HIGH\|LOW\|INPUT\|OUTPUT\|INPUT_PULLUP\)\>"
        syntax match arduinoType "\<\(byte\|boolean\|String\)\>"
        syntax match arduinoSerial "\<Serial\>"
        
        highlight link arduinoFunction Function
        highlight link arduinoConstant Constant
        highlight link arduinoType Type
        highlight link arduinoSerial Special
      ]])
    end,
  })
  
  -- Configuración específica para el tipo de archivo Arduino
  vim.api.nvim_create_autocmd("FileType", {
    group = arduino_group,
    pattern = "arduino",
    callback = function()
      -- Configuración de indentación
      vim.bo.cindent = true
      vim.bo.smartindent = true
      vim.bo.expandtab = true
      vim.bo.tabstop = 2
      vim.bo.shiftwidth = 2
      vim.bo.softtabstop = 2
      vim.bo.textwidth = 100
      
      -- Configurar comentarios
      vim.bo.commentstring = "// %s"
      
      -- Configurar matchpairs para mejor navegación
      vim.bo.matchpairs = "(:),{:},[:]"
      
      -- Palabras clave específicas de Arduino
      vim.bo.iskeyword = vim.bo.iskeyword .. ",#"
    end,
  })
  
  -- Autodetectar proyectos Arduino y configurar path
  vim.api.nvim_create_autocmd("VimEnter", {
    group = arduino_group,
    callback = function()
      if M.is_arduino_project() then
        -- Añadir rutas comunes de Arduino al path de búsqueda
        vim.opt.path:append("lib/**")
        vim.opt.path:append("src/**")
        vim.opt.path:append("include/**")
        
        -- Configurar suffixes para incluir archivos comunes de Arduino
        vim.opt.suffixesadd:append(".ino")
        vim.opt.suffixesadd:append(".h")
        vim.opt.suffixesadd:append(".cpp")
      end
    end,
  })
end

return M
