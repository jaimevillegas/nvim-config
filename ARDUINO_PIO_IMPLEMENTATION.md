# Arduino & PlatformIO Integration for Neovim

Integración completa de Arduino CLI y PlatformIO en Neovim con detección automática de tipo de proyecto, menús interactivos y soporte completo para desarrollo de firmware embebido.

## 📋 Tabla de Contenidos

- [Características](#características)
- [Requisitos](#requisitos)
- [Arquitectura](#arquitectura)
- [Instalación](#instalación)
- [Guía de Uso](#guía-de-uso)
- [Keybindings](#keybindings)
- [Configuración](#configuración)
- [Troubleshooting](#troubleshooting)
- [Ejemplos](#ejemplos)

---

## ✨ Características

### Arduino CLI
- ✅ Compilación y verificación de sketches con output verbose
- ✅ Upload a placas Arduino/ESP32/ESP8266
- ✅ Monitor serial integrado con baudrate configurable
- ✅ Selección interactiva de placas (boards)
- ✅ Selección interactiva de puertos seriales
- ✅ Selección de baudrate para monitor serial
- ✅ Gestión de librerías (buscar, instalar, listar, actualizar)
- ✅ Gestión de cores (instalar, actualizar, listar)
- ✅ Creación de nuevos sketches
- ✅ Mostrar información de configuración actual

### PlatformIO
- ✅ Acceso completo a comandos PlatformIO
- ✅ Build, Upload, Monitor, Debug
- ✅ Gestión de plataformas y dependencias
- ✅ Testing y compilación de filesystem
- ✅ Soporte para desarrollo remoto
- ✅ Integración con toggleterm para terminales flotantes

### Funcionalidades Inteligentes
- 🔍 Detección automática de tipo de proyecto (Arduino vs PlatformIO)
- 🎯 Comandos contextuales basados en el proyecto
- 📊 Output verbose para debug detallado
- 🎨 Menús interactivos con vim.ui.select
- ⌨️ Integración con which-key para menus jerárquicos

---

## 📦 Requisitos

### Requisitos Obligatorios

#### 1. Neovim
```bash
# Versión mínima: 0.8+
nvim --version
```

#### 2. Arduino CLI
```bash
# Instalación en Arch Linux
sudo pacman -S arduino-cli

# Instalación manual
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh

# Verificar instalación
arduino-cli version
```

#### 3. PlatformIO Core (opcional, para proyectos PlatformIO)
```bash
# Instalación con pip
pip install platformio

# Verificar instalación
pio --version
```

### Dependencias de Neovim

#### Plugins Requeridos
- **lazy.nvim** - Plugin manager
- **nvim-toggleterm.lua** - Terminal flotante integrado
- **nvim-platformio.lua** - Plugin de PlatformIO (opcional)
- **which-key.nvim** - Menús de ayuda (opcional pero recomendado)

#### Plugins Opcionales
- **nvim-telescope** - Para mejores selectores
- **nvim-treesitter** - Sintaxis mejorada para C/C++
- **LuaSnip** - Snippets de Arduino

---

## 🏗️ Arquitectura

### Estructura de Archivos

```
~/.config/nvim/
├── init.lua                              # Entry point, carga módulos
├── lua/
│   ├── arduino-cli/
│   │   └── init.lua                      # Wrapper de arduino-cli
│   ├── config/
│   │   ├── arduino.lua                   # Configuración Arduino (sintaxis, ftdetect)
│   │   ├── arduino-keymaps.lua           # Keybindings unificados
│   │   └── lazy.lua                      # Configuración de lazy.nvim
│   └── plugins/
│       ├── arduino.lua                   # Plugin de sintaxis Arduino
│       └── platformio.lua                # Plugin nvim-platformio
└── after/
    ├── ftdetect/
    │   └── arduino.vim                   # Detección de archivos .ino
    └── syntax/
        └── arduino.vim                   # Sintaxis Arduino
```

### Módulos Principales

#### 1. `lua/arduino-cli/init.lua`
Módulo wrapper que encapsula todas las funciones de arduino-cli:

**Funciones principales:**
- `check_arduino_cli()` - Verifica instalación de arduino-cli
- `exec_in_term(cmd, name)` - Ejecuta comandos en terminal flotante
- `get_sketch_info()` - Obtiene información del sketch actual
- `compile()` - Compila con flag --verbose
- `upload()` - Sube código a la placa
- `compile_and_upload()` - Compila y sube en un comando
- `select_board()` - UI para seleccionar placa
- `select_port()` - UI para seleccionar puerto
- `select_baudrate()` - UI para seleccionar baudrate
- `serial_monitor()` - Abre monitor serial
- `search_library()` - Busca librerías
- `install_library()` - Instala librerías
- `list_libraries()` - Lista librerías instaladas
- `update_libraries()` - Actualiza librerías
- `install_core()` - Instala cores (ej: esp32:esp32)
- `update_cores()` - Actualiza cores instalados
- `list_cores()` - Lista cores instalados
- `update_index()` - Actualiza índice de paquetes
- `new_sketch()` - Crea nuevo sketch
- `show_config()` - Muestra configuración actual

#### 2. `lua/config/arduino-keymaps.lua`
Configura todos los keybindings y detección de proyecto:

**Funcionalidades:**
- Detección automática de proyecto (platformio.ini vs .ino)
- Registro de keybindings bajo `<leader>a`
- Integración con which-key
- Autocommands para detección de tipo de archivo
- Configuración de variables globales por defecto

**Variables globales gestionadas:**
- `vim.g.arduino_board` - FQBN de la placa (ej: "esp32:esp32:esp32")
- `vim.g.arduino_port` - Puerto serial (ej: "/dev/ttyUSB0")
- `vim.g.arduino_baudrate` - Baudrate para serial (ej: "115200")

#### 3. `lua/config/arduino.lua`
Configuración específica de Arduino:
- Detección de archivos .ino
- Configuración de sintaxis
- Helpers para proyectos Arduino

#### 4. `lua/plugins/platformio.lua`
Configuración del plugin nvim-platformio:
- Lazy loading de comandos PlatformIO
- Integración con toggleterm
- Comandos disponibles: Pioinit, Piorun, Piomon, etc.

---

## 🚀 Instalación

### Paso 1: Instalar Arduino CLI

```bash
# Arch Linux
sudo pacman -S arduino-cli

# Configurar arduino-cli
arduino-cli config init

# Actualizar índice de paquetes
arduino-cli core update-index

# Instalar core de Arduino (ejemplo para AVR)
arduino-cli core install arduino:avr

# Instalar core de ESP32 (si usas ESP32)
arduino-cli core install esp32:esp32
```

### Paso 2: Verificar archivos de configuración

Los archivos ya deberían estar en tu configuración de Neovim:
- ✅ `lua/arduino-cli/init.lua`
- ✅ `lua/config/arduino-keymaps.lua`
- ✅ `lua/plugins/arduino.lua`
- ✅ `lua/plugins/platformio.lua`

### Paso 3: Cargar configuración

En tu `init.lua` debe haber:
```lua
-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Configuración específica para Arduino
require("config.arduino").setup()

-- Keybindings unificados para Arduino/PlatformIO
require("config.arduino-keymaps")
```

### Paso 4: Instalar plugins

```vim
:Lazy sync
```

### Paso 5: Verificar instalación

```vim
:checkhealth
```

---

## 📖 Guía de Uso

### Configuración Inicial (Primera Vez)

#### 1. Actualizar índice de Arduino CLI
```vim
<leader>aCU
```
Esto actualiza la lista de cores y placas disponibles.

#### 2. Instalar core de tu placa
```vim
<leader>aCi
```
Ejemplos:
- Arduino AVR: `arduino:avr`
- ESP32: `esp32:esp32`
- ESP8266: `esp8266:esp8266`

#### 3. Seleccionar placa (board)
```vim
<leader>aB
```
Se mostrará un selector con todas las placas del core instalado.

#### 4. Seleccionar puerto serial
```vim
<leader>aP
```
Detecta automáticamente placas conectadas.

#### 5. Seleccionar baudrate (para monitor serial)
```vim
<leader>aS
```
Baudrates comunes:
- 9600 (Arduino Uno)
- 115200 (ESP32/ESP8266)

#### 6. Verificar configuración
```vim
<leader>ai
```
Muestra: Board, Port y Baudrate actual.

### Flujo de Trabajo Típico

#### Proyecto Arduino (.ino)

```vim
# 1. Abrir sketch
nvim mi_proyecto/mi_proyecto.ino

# 2. Editar código
# ... tu código aquí ...

# 3. Compilar y verificar
<leader>ab

# 4. Subir a la placa
<leader>au

# 5. Abrir monitor serial
<leader>am

# O todo junto:
<leader>aU  # Compila y sube en un comando
```

#### Proyecto PlatformIO

```vim
# 1. Abrir proyecto
nvim platformio_project/

# 2. Editar código en src/main.cpp
# ... tu código aquí ...

# 3. Build
<leader>ab    # Usa automáticamente PlatformIO

# 4. Upload
<leader>au

# 5. Monitor
<leader>am

# Comandos específicos de PlatformIO:
<leader>api   # Inicializar proyecto
<leader>apd   # Debug
<leader>apt   # Tests
```

### Gestión de Librerías

#### Buscar librería
```vim
<leader>als
# Ingresa: DHT sensor library
```

#### Instalar librería
```vim
<leader>ali
# Ingresa: "DHT sensor library"
```

#### Listar librerías instaladas
```vim
<leader>all
```

#### Actualizar todas las librerías
```vim
<leader>alu
```

### Gestión de Cores

#### Listar cores instalados
```vim
<leader>aCl
```

#### Actualizar cores
```vim
<leader>aCu
```

---

## ⌨️ Keybindings

### Comandos Principales (Smart Detection)

Estos comandos detectan automáticamente si estás en un proyecto Arduino o PlatformIO:

| Keybinding | Descripción | Arduino CLI | PlatformIO |
|------------|-------------|-------------|------------|
| `<leader>ab` | Build/Compilar | `compile --verbose` | `pio run` |
| `<leader>au` | Upload | `upload --verbose` | `pio run -t upload` |
| `<leader>am` | Monitor Serial | `monitor` | `pio device monitor` |
| `<leader>ac` | Clean/Compile | `compile` | `pio run -t clean` |
| `<leader>av` | Verify | `compile --verbose` | - |

### Arduino CLI Específico

| Keybinding | Descripción |
|------------|-------------|
| `<leader>aB` | Seleccionar Board (placa) |
| `<leader>aP` | Seleccionar Puerto Serial |
| `<leader>aS` | Seleccionar Baudrate |
| `<leader>aD` | Listar Dispositivos/Boards |
| `<leader>aU` | Build & Upload (un solo comando) |
| `<leader>ai` | Mostrar Configuración Actual |

### Librerías (`<leader>al`)

| Keybinding | Descripción |
|------------|-------------|
| `<leader>als` | Buscar librería |
| `<leader>ali` | Instalar librería |
| `<leader>all` | Listar librerías instaladas |
| `<leader>alu` | Actualizar todas las librerías |

### Cores (`<leader>aC`)

| Keybinding | Descripción |
|------------|-------------|
| `<leader>aCi` | Instalar core |
| `<leader>aCu` | Actualizar cores |
| `<leader>aCl` | Listar cores instalados |
| `<leader>aCU` | Actualizar índice de paquetes |

### Sketch (`<leader>as`)

| Keybinding | Descripción |
|------------|-------------|
| `<leader>asn` | Crear nuevo sketch |

### PlatformIO Específico (`<leader>ap`)

| Keybinding | Descripción |
|------------|-------------|
| `<leader>api` | Inicializar proyecto PlatformIO |
| `<leader>apb` | Build PlatformIO |
| `<leader>apu` | Upload PlatformIO |
| `<leader>apm` | Monitor PlatformIO |
| `<leader>apd` | Debug PlatformIO |
| `<leader>apc` | Clean PlatformIO |
| `<leader>apt` | Test PlatformIO |
| `<leader>apl` | Gestión de librerías PlatformIO |
| `<leader>aph` | Ayuda PlatformIO |
| `<leader>apf` | Menú completo PlatformIO |

---

## ⚙️ Configuración

### Variables Globales

Puedes configurar estas variables en tu `init.lua` o cambiarlas dinámicamente:

```lua
-- Board por defecto (FQBN - Fully Qualified Board Name)
vim.g.arduino_board = "esp32:esp32:esp32"        -- ESP32 genérico
-- vim.g.arduino_board = "arduino:avr:uno"       -- Arduino Uno
-- vim.g.arduino_board = "esp8266:esp8266:generic" -- ESP8266

-- Puerto serial por defecto
vim.g.arduino_port = "/dev/ttyUSB0"              -- Linux
-- vim.g.arduino_port = "/dev/ttyACM0"           -- Linux (algunos Arduino)
-- vim.g.arduino_port = "COM3"                   -- Windows

-- Baudrate para monitor serial
vim.g.arduino_baudrate = "115200"                -- ESP32/ESP8266
-- vim.g.arduino_baudrate = "9600"               -- Arduino Uno
```

### Encontrar FQBN de tu placa

```bash
# Listar todas las placas disponibles
arduino-cli board listall

# Buscar una placa específica
arduino-cli board listall | grep -i "esp32"

# Detectar placa conectada
arduino-cli board list
```

### Configurar Toggleterm

Puedes personalizar el comportamiento de las terminales flotantes en `lua/plugins/platformio.lua`:

```lua
{
  "akinsho/nvim-toggleterm.lua",
  version = "*",
  opts = {
    size = 20,
    open_mapping = [[<c-\>]],
    hide_numbers = true,
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    persist_size = true,
    direction = 'float',  -- 'vertical' | 'horizontal' | 'tab' | 'float'
    close_on_exit = false,
    float_opts = {
      border = 'curved',
      width = 120,
      height = 30,
    },
  },
},
```

---

## 🔧 Troubleshooting

### Arduino CLI no encontrado

**Síntoma:** Error "arduino-cli not found"

**Solución:**
```bash
# Verificar instalación
which arduino-cli

# Si no está instalado
sudo pacman -S arduino-cli  # Arch
# o instalar manualmente
```

### No detecta la placa conectada

**Síntoma:** `<leader>aP` no muestra placas

**Soluciones:**
```bash
# 1. Verificar que la placa esté conectada
arduino-cli board list

# 2. Verificar permisos del puerto serial
sudo usermod -a -G uucp $USER  # Arch
sudo usermod -a -G dialout $USER  # Ubuntu/Debian
# Cerrar sesión y volver a entrar

# 3. Verificar que el puerto existe
ls -l /dev/ttyUSB* /dev/ttyACM*
```

### Error al compilar: "Platform not installed"

**Síntoma:** Error al compilar sobre core no instalado

**Solución:**
```vim
# 1. Actualizar índice
<leader>aCU

# 2. Instalar core
<leader>aCi
# Ejemplo para ESP32: esp32:esp32

# 3. Verificar instalación
<leader>aCl
```

### Error al compilar: "FQBN not valid"

**Síntoma:** Board FQBN inválido

**Solución:**
```bash
# Verificar FQBN correcto
arduino-cli board listall | grep -i "tu_placa"

# Configurar en Neovim
:lua vim.g.arduino_board = "esp32:esp32:esp32"
```

### Terminal flotante no aparece

**Síntoma:** Al compilar no se muestra la terminal

**Solución:**
```vim
# 1. Verificar instalación de toggleterm
:Lazy

# 2. Reinstalar toggleterm
:Lazy sync

# 3. Verificar que toggleterm funciona
:ToggleTerm
```

### Compilación exitosa pero no muestra información

**Síntoma:** El build termina pero no se ve output

**Solución:**
Los comandos ahora usan `--verbose` por defecto. Si no ves output:
```vim
# Compilar manualmente para ver errores
:terminal arduino-cli compile --verbose --fqbn esp32:esp32:esp32 .
```

### Baudrate incorrecto en monitor serial

**Síntoma:** Caracteres basura en monitor serial

**Solución:**
```vim
# Cambiar baudrate
<leader>aS
# Seleccionar el baudrate correcto (115200 para ESP32, 9600 para Arduino Uno)

# Verificar baudrate en tu código
// En setup():
Serial.begin(115200);  // Debe coincidir con vim.g.arduino_baudrate
```

---

## 💡 Ejemplos

### Ejemplo 1: Proyecto Blink Arduino Uno

```vim
# 1. Crear nuevo sketch
<leader>asn
# Nombre: blink

# 2. Editar blink.ino
void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  digitalWrite(LED_BUILTIN, HIGH);
  delay(1000);
  digitalWrite(LED_BUILTIN, LOW);
  delay(1000);
}

# 3. Configurar
<leader>aB    # Seleccionar: Arduino Uno
<leader>aP    # Seleccionar: /dev/ttyACM0

# 4. Compilar y subir
<leader>aU

# Output esperado:
# Sketch uses 924 bytes (2%) of program storage space...
# Global variables use 9 bytes (0%) of dynamic memory...
```

### Ejemplo 2: Proyecto ESP32 con Serial

```vim
# 1. Editar sketch
void setup() {
  Serial.begin(115200);
  pinMode(2, OUTPUT);  // LED integrado ESP32
}

void loop() {
  digitalWrite(2, HIGH);
  Serial.println("LED ON");
  delay(1000);
  digitalWrite(2, LOW);
  Serial.println("LED OFF");
  delay(1000);
}

# 2. Configurar
<leader>aB    # ESP32 Dev Module
<leader>aP    # /dev/ttyUSB0
<leader>aS    # 115200

# 3. Compilar y subir
<leader>aU

# 4. Abrir monitor serial
<leader>am

# Output esperado en serial:
# LED ON
# LED OFF
# LED ON
# LED OFF
```

### Ejemplo 3: Instalar y usar librería DHT

```vim
# 1. Buscar librería
<leader>als
# Buscar: DHT sensor

# 2. Instalar librería
<leader>ali
# Instalar: DHT sensor library

# 3. Usar en código
#include <DHT.h>

#define DHTPIN 4
#define DHTTYPE DHT22

DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(115200);
  dht.begin();
}

void loop() {
  float h = dht.readHumidity();
  float t = dht.readTemperature();

  Serial.print("Humidity: ");
  Serial.print(h);
  Serial.print("%  Temperature: ");
  Serial.print(t);
  Serial.println("°C");

  delay(2000);
}

# 4. Compilar y probar
<leader>aU
<leader>am
```

### Ejemplo 4: Proyecto PlatformIO ESP32

```bash
# Fuera de Neovim: crear proyecto
mkdir mi_proyecto_pio
cd mi_proyecto_pio
pio project init --board esp32dev
```

```vim
# En Neovim
nvim src/main.cpp

# Código
#include <Arduino.h>

void setup() {
  Serial.begin(115200);
  pinMode(2, OUTPUT);
}

void loop() {
  digitalWrite(2, !digitalRead(2));
  Serial.println("Toggle!");
  delay(500);
}

# Compilar y subir (detecta automáticamente PlatformIO)
<leader>aU

# Monitor
<leader>am
```

---

## 📚 Referencias

### Documentación Oficial
- [Arduino CLI Documentation](https://arduino.github.io/arduino-cli/)
- [PlatformIO Documentation](https://docs.platformio.org/)
- [Neovim Lua Guide](https://neovim.io/doc/user/lua-guide.html)

### Comandos Arduino CLI útiles

```bash
# Listar cores disponibles
arduino-cli core search

# Información de una placa
arduino-cli board details esp32:esp32:esp32

# Listar librerías
arduino-cli lib search sensor

# Información de librería
arduino-cli lib search DHT --names

# Compilar con output completo
arduino-cli compile --verbose --fqbn esp32:esp32:esp32 .

# Upload con output completo
arduino-cli upload --verbose --fqbn esp32:esp32:esp32 --port /dev/ttyUSB0 .

# Monitor serial directo
arduino-cli monitor --port /dev/ttyUSB0 --config baudrate=115200
```

### FQBNs Comunes

| Placa | FQBN |
|-------|------|
| Arduino Uno | `arduino:avr:uno` |
| Arduino Mega | `arduino:avr:mega` |
| Arduino Nano | `arduino:avr:nano` |
| ESP32 Dev Module | `esp32:esp32:esp32` |
| ESP32-S3 | `esp32:esp32:esp32s3` |
| ESP32-C3 | `esp32:esp32:esp32c3` |
| ESP8266 Generic | `esp8266:esp8266:generic` |
| NodeMCU 1.0 | `esp8266:esp8266:nodemcuv2` |

---

## 🎯 Tips y Trucos

### Cambiar rápidamente entre placas

```lua
-- Crear comandos personalizados en tu init.lua
vim.api.nvim_create_user_command('ArduinoUno', function()
  vim.g.arduino_board = 'arduino:avr:uno'
  vim.g.arduino_baudrate = '9600'
  vim.notify('Configured for Arduino Uno', vim.log.levels.INFO)
end, {})

vim.api.nvim_create_user_command('ESP32', function()
  vim.g.arduino_board = 'esp32:esp32:esp32'
  vim.g.arduino_baudrate = '115200'
  vim.notify('Configured for ESP32', vim.log.levels.INFO)
end, {})
```

Uso:
```vim
:ArduinoUno
:ESP32
```

### Mapear teclas de función para workflow rápido

```lua
-- En arduino-keymaps.lua o init.lua
vim.keymap.set("n", "<F5>", function()
  require("arduino-cli").compile()
end, { desc = "Arduino: Compile" })

vim.keymap.set("n", "<F6>", function()
  require("arduino-cli").upload()
end, { desc = "Arduino: Upload" })

vim.keymap.set("n", "<F7>", function()
  require("arduino-cli").serial_monitor()
end, { desc = "Arduino: Serial Monitor" })
```

### Ver tamaño del sketch rápidamente

El output verbose ahora muestra automáticamente:
```
Sketch uses 234532 bytes (17%) of program storage space. Maximum is 1310720 bytes.
Global variables use 15204 bytes (4%) of dynamic memory, leaving 312476 bytes for local variables.
```

---

## 📝 Notas de Desarrollo

### Cambios Recientes

**v1.0.0** (2025-01-30)
- ✅ Implementación inicial de arduino-cli wrapper
- ✅ Integración con PlatformIO
- ✅ Detección automática de tipo de proyecto
- ✅ Selector de baudrate para monitor serial
- ✅ Output verbose en compile/upload
- ✅ Menús interactivos con vim.ui.select
- ✅ Integración con which-key
- ✅ Soporte para ESP32/ESP8266/Arduino
- ✅ Gestión completa de librerías y cores

### Próximas Mejoras Planeadas

- [ ] Auto-detección de baudrate desde código
- [ ] Snippets mejorados para Arduino
- [ ] Integración con nvim-dap para debugging
- [ ] Soporte para múltiples placas simultáneas
- [ ] Cache de configuraciones por proyecto
- [ ] Auto-selección de puerto cuando solo hay uno
- [ ] Previsualización de librerías antes de instalar
- [ ] Gestor visual de cores instalados

---

## 🤝 Contribuciones

Esta implementación es parte de la configuración personal de Neovim. Para sugerencias o mejoras:

1. Probar la funcionalidad
2. Documentar el problema/mejora
3. Proponer solución
4. Actualizar documentación

---

## 📄 Licencia

Esta configuración es de uso personal. Siéntete libre de adaptar y modificar según tus necesidades.

---

**Última actualización:** 2025-01-30
**Autor:** Configuración personalizada de Neovim
**Versión:** 1.0.0
