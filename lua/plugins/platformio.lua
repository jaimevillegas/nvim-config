return {
  -- Terminal para mostrar la salida de PlatformIO
  {
    "akinsho/nvim-toggleterm.lua",
    version = "*",
    opts = {
      -- opciones de configuración para toggleterm si son necesarias
    },
  },
  -- Plugin de PlatformIO
  {
    "anurag3301/nvim-platformio.lua",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "akinsho/nvim-toggleterm.lua",
    },
    cmd = {
      "Pioinit",
      "Piorun",
      "Piocmdh",
      "Piocmdf",
      "Piolib",
      "Piomon",
      "Piodebug",
      "Piodb",
    },
    config = function()
      require("platformio").setup({
        -- Tu configuración aquí si es necesario
      })
    end,
  },
}
