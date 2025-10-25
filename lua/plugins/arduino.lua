return {
  -- Treesitter para resaltado de sintaxis mejorado
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Asegurar que C y C++ están instalados para Arduino
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "c", "cpp", "arduino" })

      return opts
    end,
  },

  -- Plugin específico para Arduino
  {
    "sudar/vim-arduino-syntax",
    ft = { "arduino" },
    config = function()
      -- Configuración para archivos .ino
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*.ino",
        callback = function()
          vim.bo.filetype = "arduino"
        end,
      })

      -- Configuración adicional para archivos Arduino
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "arduino",
        callback = function()
          -- Usar la misma configuración que C++
          vim.bo.commentstring = "// %s"
          vim.bo.cindent = true
          vim.bo.smartindent = true
          vim.bo.expandtab = true
          vim.bo.tabstop = 2
          vim.bo.shiftwidth = 2
          vim.bo.softtabstop = 2
        end,
      })
    end,
  },

  -- LSP para C/C++ que también funcionará con Arduino
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {},
    },
  },

  -- Mejorar el resaltado de sintaxis con nvim-colorizer
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("colorizer").setup({
        filetypes = {
          "css",
          "javascript",
          "html",
          "lua",
          "arduino",
          "c",
          "cpp",
        },
        user_default_options = {
          RGB = true,
          RRGGBB = true,
          names = false,
          RRGGBBAA = true,
          rgb_fn = true,
          hsl_fn = true,
          css = true,
          css_fn = true,
          mode = "background",
        },
      })
    end,
  },

  -- Plugin para mostrar colores de LEDs en código Arduino
  {
    "rrethy/vim-hexokinase",
    build = "make hexokinase",
    ft = { "arduino", "c", "cpp" },
    config = function()
      vim.g.Hexokinase_highlighters = { "backgroundfull" }
      vim.g.Hexokinase_optInPatterns = {
        "full_hex",
        "triple_hex",
        "rgb",
        "rgba",
        "hsl",
        "hsla",
      }
    end,
  },

  -- Snippets específicos para Arduino
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()

      -- Snippets personalizados para Arduino
      local luasnip = require("luasnip")
      local s = luasnip.snippet
      local t = luasnip.text_node
      local i = luasnip.insert_node

      luasnip.add_snippets("arduino", {
        s("setup", {
          t({ "void setup() {", "  " }),
          i(1, "// Código de inicialización"),
          t({ "", "}" }),
        }),
        s("loop", {
          t({ "void loop() {", "  " }),
          i(1, "// Código principal"),
          t({ "", "}" }),
        }),
        s("pinmode", {
          t("pinMode("),
          i(1, "pin"),
          t(", "),
          i(2, "INPUT"),
          t(");"),
        }),
        s("digitalwrite", {
          t("digitalWrite("),
          i(1, "pin"),
          t(", "),
          i(2, "HIGH"),
          t(");"),
        }),
        s("digitalread", {
          t("digitalRead("),
          i(1, "pin"),
          t(")"),
        }),
        s("analogread", {
          t("analogRead("),
          i(1, "pin"),
          t(")"),
        }),
        s("analogwrite", {
          t("analogWrite("),
          i(1, "pin"),
          t(", "),
          i(2, "value"),
          t(");"),
        }),
        s("delay", {
          t("delay("),
          i(1, "1000"),
          t(");"),
        }),
        s("serial", {
          t("Serial.begin("),
          i(1, "9600"),
          t(");"),
        }),
        s("serialprint", {
          t("Serial.println("),
          i(1, '"Mensaje"'),
          t(");"),
        }),
      })
    end,
  },
}
