" Archivo de sintaxis personalizado para Arduino
" Basado en C++ pero con características específicas de Arduino

" Cargar sintaxis base de C++
runtime! syntax/cpp.vim

" Palabras clave específicas de Arduino
syntax keyword arduinoFunction setup loop
syntax keyword arduinoFunction pinMode digitalWrite digitalRead
syntax keyword arduinoFunction analogRead analogWrite analogReference
syntax keyword arduinoFunction tone noTone pulseIn shiftOut shiftIn
syntax keyword arduinoFunction attachInterrupt detachInterrupt interrupts noInterrupts
syntax keyword arduinoFunction millis micros delay delayMicroseconds
syntax keyword arduinoFunction map constrain min max abs
syntax keyword arduinoFunction randomSeed random
syntax keyword arduinoFunction bit bitRead bitWrite bitSet bitClear
syntax keyword arduinoFunction lowByte highByte
syntax keyword arduinoFunction sizeof

" Constantes de Arduino
syntax keyword arduinoConstant HIGH LOW
syntax keyword arduinoConstant INPUT OUTPUT INPUT_PULLUP
syntax keyword arduinoConstant LED_BUILTIN
syntax keyword arduinoConstant A0 A1 A2 A3 A4 A5 A6 A7
syntax keyword arduinoConstant RISING FALLING CHANGE
syntax keyword arduinoConstant DEFAULT INTERNAL EXTERNAL
syntax keyword arduinoConstant DEC BIN HEX OCT
syntax keyword arduinoConstant PI HALF_PI TWO_PI
syntax keyword arduinoConstant LSBFIRST MSBFIRST

" Tipos de datos específicos de Arduino
syntax keyword arduinoType byte boolean String
syntax keyword arduinoType word

" Objetos Serial
syntax keyword arduinoSerial Serial Serial1 Serial2 Serial3
syntax keyword arduinoSerialFunc begin end available read peek flush print println write
syntax keyword arduinoSerialFunc find findUntil parseInt parseFloat readBytes readBytesUntil
syntax keyword arduinoSerialFunc readString readStringUntil setTimeout

" Wire (I2C)
syntax keyword arduinoWire Wire
syntax keyword arduinoWireFunc requestFrom beginTransmission endTransmission
syntax keyword arduinoWireFunc send receive onReceive onRequest

" SPI
syntax keyword arduinoSPI SPI
syntax keyword arduinoSPIFunc begin end transfer setBitOrder setDataMode setClockDivider

" EEPROM
syntax keyword arduinoEEPROM EEPROM
syntax keyword arduinoEEPROMFunc read write update get put length

" Servo
syntax keyword arduinoServo Servo
syntax keyword arduinoServoFunc attach detach write writeMicroseconds read attached

" Software Serial
syntax keyword arduinoSoftSerial SoftwareSerial

" Pines digitales comunes en Arduino
syntax match arduinoPin "\<\d\+\>" contained
syntax match arduinoPinUsage "\(pinMode\|digitalWrite\|digitalRead\)\s*(\s*\zs\d\+\ze\s*[,)]" contains=arduinoPin

" Números hexadecimales (comunes en programación de Arduino)
syntax match arduinoHex "\<0[xX][0-9a-fA-F]\+\>"

" Comentarios específicos de Arduino (para TODO, FIXME, etc.)
syntax match arduinoTodo "\(TODO\|FIXME\|NOTE\|HACK\|WARNING\):" contained containedin=.*Comment.*

" Highlight groups
highlight default link arduinoFunction Function
highlight default link arduinoConstant Constant
highlight default link arduinoType Type
highlight default link arduinoSerial Special
highlight default link arduinoSerialFunc Function
highlight default link arduinoWire Special
highlight default link arduinoWireFunc Function
highlight default link arduinoSPI Special
highlight default link arduinoSPIFunc Function
highlight default link arduinoEEPROM Special
highlight default link arduinoEEPROMFunc Function
highlight default link arduinoServo Special
highlight default link arduinoServoFunc Function
highlight default link arduinoSoftSerial Special
highlight default link arduinoPin Number
highlight default link arduinoHex Number
highlight default link arduinoTodo Todo

" Folding para funciones Arduino
syntax region arduinoFold start="{" end="}" transparent fold
