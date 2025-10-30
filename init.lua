-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Configuración específica para Arduino
require("config.arduino").setup()

-- Keybindings unificados para Arduino/PlatformIO
require("config.arduino-keymaps")
