/*
Основные концепции языка:
Проект (Project), Продукт (Product), Артефакт (Artifact), Модуль (Module), Правило (Rule), Группа(Group), Зависимость (Depends), Тег (Tag).
Продукт — это аналог pro или vcproj, т. е. одна цель для сборки.
Проект — это набор ваших продуктов вместе с зависимостями, воспринимаемый системой сборки как одно целое. Один проект — один граф сборки.
Тег — система классификации файлов. Например «*.cpp» => «cpp»
Правило — Преобразование файлов проекта, отмеченных определенными тегами. Генерирует другие файлы, называемые Артефактами.
Как правило, это компиляторы или другие системы сборки.
Артефакт — файл, над который является выходным для правила (и возможно, входным для другиx правил). Это обычно «obj», «exe» файлы.
У многих QML-объектов есть свойство condition, которое отвечает за то, будет собираться он или нет. А если нам необходимо разделить так файлы?
Для этого их можно объединить в группу (Group)
Rule умеет срабатывать на каждый файл, попадающий под что-то. Может срабатывать по разу на каждый фаил (например, для вызова компилятора), а может один раз на все (линкер).
Transformer предназначен для срабатывания только на один фаил, с заранее определенным именем. Например, прошивальщик или какой-нибудь хитрый скрипт.
флаг multiplex, который говорит о том, что это правило обрабатывает сразу все файлы данного типа скопом.
*/

import qbs
import qbs.FileInfo
import qbs.ModUtils
import qbs.Probes

Product {
    consoleApplication: true

    property string ARDUINO_DIR: "C:/Program Files (x86)/Arduino/hardware/arduino/avr"
    property string ARDUINO_LIB: "Ваша директория установки библиотек Arduino"
    property string ARDUINO_MCU: "atmega328p"

    type: [
        "application",
        "hex",
    ]

    Depends { name:"cpp" }

    Group {
        name: "App (Sketch)"
        prefix: path
        files: [
            "/**/*.c",
            "/**/*.cpp",
            "/**/*.h",
        ]
        excludeFiles: [
        ]
    }


    Group {
        name: "Arduino Core"
        prefix: ARDUINO_DIR
        files: [
            //Заголовки Arduino Core
            "/cores/arduino/*.h",
            "/variants/standard/*.h",

            //Исходники Arduino Core
            "/cores/arduino/*.c",
            "/cores/arduino/*.cpp",

            "/libraries/**/*.c",
            "/libraries/**/*.cpp",
            "/libraries/**/*.h",
            "/libraries/**/*.s",
        ]
        excludeFiles: [
        ]
    }

    Group {
        name: "Arduino Libraries"
        prefix: ARDUINO_LIB
        files: [
            "/**/*.c",
            "/**/*.cpp",
            "/**/*.h",
        ]
        excludeFiles: [
            "/DallasTemperature/**/*"
        ]
    }

    cpp.debugInformation: false
    cpp.enableExceptions: false // passes -fno-exceptions
    cpp.executableSuffix: ".elf"
    cpp.optimization: "small" // passes -Os
    cpp.positionIndependentCode: false
    //cpp.warningLevel: "none" // passes -w
    cpp.warningLevel: "all"

    cpp.cxxLanguageVersion: "c++17"

    cpp.defines: [
        "ARDUINO=10813",
        "ARDUINO_ARCH_AVR",
        "ARDUINO_AVR_UNO",
        "F_CPU=16000000L",
        "__AVR_ATmega328P__",
        "__PROG_TYPES_COMPAT__",
    ]

    cpp.cxxFlags: [
        "-fno-rtti",
        "-fno-threadsafe-statics",
        "-fpermissive",
    ]

    cpp.cFlags: [
        "-std=gnu11",
    ]

    cpp.commonCompilerFlags: [
        "-mmcu="+ARDUINO_MCU,
        "-MMD",
        "-fdata-sections",
        "-ffunction-sections",
        //"-Wno-unused-parameter",
        //"-funsigned-char",
    ]

    cpp.driverLinkerFlags:[
        "-mmcu="+ARDUINO_MCU,
        "-flto",
        "-fuse-linker-plugin",
        "-Wl,--gc-sections",
    ]

    cpp.linkerFlags:[
        "-flto",
        "--gc-sections",
        "-lc",
        "-lm",
        //"-lstdc++",
        //"-lsupc++",
    ]

    cpp.includePaths: [
        path,
        ARDUINO_DIR+"/cores/arduino/",
        ARDUINO_DIR+"/libraries/",
        ARDUINO_DIR+"/libraries/EEPROM/src/",
        ARDUINO_DIR+"/libraries/SPI/src/",
        ARDUINO_DIR+"/libraries/SoftwareSerial/src/",
        ARDUINO_DIR+"/libraries/Wire/src/",
        ARDUINO_DIR+"/libraries/Wire/src/utility/",
        ARDUINO_DIR+"/variants/standard/",
        //        ARDUINO_LIB+"/Adafruit_MCP4725/",
        //        ARDUINO_LIB+"/LiquidCrystal_I2C/",
        //        ARDUINO_LIB+"/OneButton/src/",
        //        ARDUINO_LIB+"/OneWire/",
    ]

    Rule
    {
        inputs: ["application"]

        Artifact
        {
            filePath: project.buildDirectory + product.name + ".hex"
            fileTags: "hex"
        }

        prepare:
        {
            var argsSize = [
                        input.filePath,
                        "--mcu="+product.ARDUINO_MCU,
                        "-C",
                        "--format=avr"
                    ]
            var argsObjcopyHex = [
                        "-O", "ihex",
                        "-j", ".text",
                        "-j", ".data",
                        input.filePath,
                        output.filePath
                    ]
            var argsObjcopyBin = [
                        "-O", "binary",
                        "-S", "-g",
                        input.filePath,
                        project.buildDirectory + product.name + ".bin"
                    ]
            var argsFlashing = [
                        "-c", "arduino",
                        "-p", "m328p",
                        "-P", "COM5",
                        "-b", "115200",
                        "-U", "flash:w:"+output.filePath+":i"
                    ]

            var cmdSize = new Command( "avr-size.exe", argsSize)
            var cmdObjcopyHex = new Command( "avr-objcopy.exe", argsObjcopyHex)
            var cmdObjcopyBin = new Command( "avr-objcopy.exe", argsObjcopyBin)

            /*
            Если не работает то скопировать "avrdude.conf" из
            C:\Program Files (x86)\Arduino\hardware\arduino\avr\bootloaders\gemma
            в
            C:/Program Files (x86)\Arduino\hardware\tools\avr\bin
            */
            var cmdFlash = new Command( "avrdude.exe", argsFlashing);

            cmdSize.description = "Size of sections:"
            cmdSize.highlight = "filegen"

            cmdObjcopyHex.description = "convert to hex..."
            cmdObjcopyHex.highlight = "filegen"

            cmdObjcopyBin.description = "convert to bin..."
            cmdObjcopyBin.highlight = "filegen"

            cmdFlash.description = "download firmware to uC..."
            cmdFlash.highlight = "filegen"
            return [
                        cmdSize,
                        cmdObjcopyHex,
                        cmdObjcopyBin,
                        // cmdFlash // Закомметировать если не нужно шить
                    ]
        }
    }
}


