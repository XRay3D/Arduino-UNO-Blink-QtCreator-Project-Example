//Подключаем стандартные библиотеки в стиле QML
//Основные концепции языка:
//Проект (Project), Продукт (Product), Артефакт (Artifact), Модуль (Module), Правило (Rule), Группа(Group), Зависимость (Depends), Тег (Tag).
//Продукт — это аналог pro или vcproj, т. е. одна цель для сборки.
//Проект — это набор ваших продуктов вместе с зависимостями, воспринимаемый системой сборки как одно целое. Один проект — один граф сборки.
//Тег — система классификации файлов. Например «*.cpp» => «cpp»
//Правило — Преобразование файлов проекта, отмеченных определенными тегами. Генерирует другие файлы, называемые Артефактами.
//Как правило, это компиляторы или другие системы сборки.
//Артефакт — файл, над который является выходным для правила (и возможно, входным для другиx правил). Это обычно «obj», «exe» файлы.
//У многих QML-объектов есть свойство condition, которое отвечает за то, будет собираться он или нет. А если нам необходимо разделить так файлы?
//Для этого их можно объединить в группу (Group)
//Rule умеет срабатывать на каждый файл, попадающий под что-то. Может срабатывать по разу на каждый фаил (например, для вызова компилятора), а может один раз на все (линкер).
//Transformer предназначен для срабатывания только на один фаил, с заранее определенным именем. Например, прошивальщик или какой-нибудь хитрый скрипт.
//флаг multiplex, который говорит о том, что это правило обрабатывает сразу все файлы данного типа скопом.

import qbs
import qbs.FileInfo
import qbs.ModUtils
import qbs.Probes

Product {

    consoleApplication: true

    cpp.debugInformation: true
    cpp.enableExceptions: false // passes -fno-exceptions
    cpp.executableSuffix: ".elf"
    cpp.optimization: "small" // passes -Os
    cpp.positionIndependentCode: false
    cpp.warningLevel: "none" // passes -w

    property string ARDUINO_DIR: "C:/Program Files (x86)/Arduino/hardware/arduino/avr"
    //property string ARDUINO_LIB: "C:/Users/X-Ray/Documents/Arduino/libraries"
    property string ARDUINO_MCU: "atmega328p"
    property string AVR_GCC_Path:"C:/Program Files (x86)/Arduino/hardware/tools/avr/bin/"

    type: [
        "application",
        "hex",
    ]

    Depends { name:"cpp" }

    Group {
        name: "App"
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
        name: "Arduino"
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

//    Group {
//        name: "Libraries"
//        prefix: ARDUINO_LIB
//        files: [
//            "/**/*.c",
//            "/**/*.cpp",
//            "/**/*.h",
//        ]
//        excludeFiles: [
//            "/DallasTemperature/**/*"
//        ]
//    }

    cpp.cxxLanguageVersion: "c++20"

    cpp.defines: [
        "ARDUINO=100",
        "ARDUINO_ARCH_AVR",
        "ARDUINO_AVR_UNO",
        //"ARDUINO_MAIN",
        "F_CPU=16000000L",
        "__AVR_ATmega328P__",
        "__PROG_TYPES_COMPAT__",
    ]

    cpp.cxxFlags: [
        "-std=gnu++14",
        "-fno-rtti",
        "-fno-threadsafe-statics",
        "-fpermissive",
    ]

    cpp.cFlags: [
        "-std=gnu11",
    ]

    cpp.commonCompilerFlags: [
        "-MMD",
        //"-Wno-unused-parameter",
        "-fdata-sections",
        "-ffunction-sections",
        //"-funsigned-char",
        "-mmcu="+ARDUINO_MCU,
    ]

    cpp.driverLinkerFlags:[
        "-mmcu="+ARDUINO_MCU,
        "-flto",
        "-fuse-linker-plugin",
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
//        ARDUINO_LIB+"/Adafruit_MCP4725/",
//        ARDUINO_LIB+"/LiquidCrystal_I2C/",
//        ARDUINO_LIB+"/OneButton/src/",
//        ARDUINO_LIB+"/OneWire/",
        path,

        ARDUINO_DIR+"/cores/arduino/",

        ARDUINO_DIR+"/libraries/",
        ARDUINO_DIR+"/libraries/EEPROM/src/",
        ARDUINO_DIR+"/libraries/SPI/src/",
        ARDUINO_DIR+"/libraries/SoftwareSerial/src/",
        ARDUINO_DIR+"/libraries/Wire/src/",
        ARDUINO_DIR+"/libraries/Wire/src/utility/",

        ARDUINO_DIR+"/variants/standard/",
        //ARDUINO_DIR+"/variants/circuitplay32u4/",
        //ARDUINO_DIR+"/variants/eightanaloginputs/",
        //ARDUINO_DIR+"/variants/ethernet/",
        //ARDUINO_DIR+"/variants/gemma/",
        //ARDUINO_DIR+"/variants/leonardo/",
        //ARDUINO_DIR+"/variants/mega/",
        //ARDUINO_DIR+"/variants/micro/",
        //ARDUINO_DIR+"/variants/robot_control/",
        //ARDUINO_DIR+"/variants/robot_motor/",
        //ARDUINO_DIR+"/variants/yun/",


        //ARDUINO_DIR+"/bootloaders/caterina-Arduino_Robot/",
        //ARDUINO_DIR+"/bootloaders/caterina-LilyPadUSB/",
        //ARDUINO_DIR+"/bootloaders/caterina/",
        //ARDUINO_DIR+"/bootloaders/gemma/",
        //ARDUINO_DIR+"/bootloaders/optiboot/",
        //ARDUINO_DIR+"/bootloaders/stk500v2/",
        //ARDUINO_DIR+"/firmwares/atmegaxxu2/arduino-usbdfu/",
        //ARDUINO_DIR+"/firmwares/atmegaxxu2/arduino-usbdfu/Board/",
        //ARDUINO_DIR+"/firmwares/atmegaxxu2/arduino-usbserial/",
        //ARDUINO_DIR+"/firmwares/atmegaxxu2/arduino-usbserial/Board/",
        //ARDUINO_DIR+"/firmwares/atmegaxxu2/arduino-usbserial/Lib/",
        //ARDUINO_DIR+"/libraries/HID/src/",


        //"hardware/tools/avr/avr/include/",
        //"hardware/tools/avr/avr/include/avr/",
        //"hardware/tools/avr/avr/include/compat/",
        //"hardware/tools/avr/avr/include/sys/",
        //"hardware/tools/avr/avr/include/util/",
        //"hardware/tools/avr/i686-w64-mingw32/avr/include/",
        //"hardware/tools/avr/include/gdb/",
        //"hardware/tools/avr/include/libiberty/",
        //"hardware/tools/avr/lib/gcc/avr/7.3.0/include-fixed/",
        //"hardware/tools/avr/lib/gcc/avr/7.3.0/include/",
        //"hardware/tools/avr/lib/gcc/avr/7.3.0/install-tools/",
        //"hardware/tools/avr/lib/gcc/avr/7.3.0/install-tools/include/",
        //"libraries/Adafruit_Circuit_Playground/",
        //"libraries/Adafruit_Circuit_Playground/examples/FidgetSpinner/",
        //"libraries/Adafruit_Circuit_Playground/examples/Infrared_Demos/Infrared_NeoPixel/",
        //"libraries/Adafruit_Circuit_Playground/examples/comm_badge/",
        //"libraries/Adafruit_Circuit_Playground/examples/mega_demo/",
        //"libraries/Adafruit_Circuit_Playground/utility/",
        //"libraries/Bridge/src/",
        //"libraries/Esplora/src/",
        //"libraries/Ethernet/src/",
        //"libraries/Ethernet/src/utility/",
        //"libraries/Firmata/",
        //"libraries/Firmata/examples/StandardFirmataBLE/",
        //"libraries/Firmata/examples/StandardFirmataEthernet/",
        //"libraries/Firmata/examples/StandardFirmataWiFi/",
        //"libraries/Firmata/utility/",
        //"libraries/GSM/src/",
        //"libraries/Keyboard/src/",
        //"libraries/LiquidCrystal/src/",
        //"libraries/Mouse/src/",
        //"libraries/RobotIRremote/src/",
        //"libraries/Robot_Control/examples/explore/R06_Wheel_Calibration/",
        //"libraries/Robot_Control/src/",
        //"libraries/Robot_Control/src/utility/",
        //"libraries/Robot_Motor/src/",
        //"libraries/SD/src/",
        //"libraries/SD/src/utility/",
        //"libraries/Servo/src/",
        //"libraries/Servo/src/avr/",
        //"libraries/Servo/src/megaavr/",
        //"libraries/Servo/src/nrf52/",
        //"libraries/Servo/src/sam/",
        //"libraries/Servo/src/samd/",
        //"libraries/Servo/src/stm32f4/",
        //"libraries/SpacebrewYun/src/",
        //"libraries/Stepper/src/",
        //"libraries/TFT/src/",
        //"libraries/TFT/src/utility/",
        //"libraries/Temboo/src/",
        //"libraries/Temboo/src/utility/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/CONFIG/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/BOARDS/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/BOARDS/ARDUINO/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/BOARDS/EVK1105/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/COMPONENTS/MEMORY/DATA_FLASH/AT45DBX/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/COMPONENTS/WIFI/HD/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/DRIVERS/CPU/CYCLE_COUNTER/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/DRIVERS/EBI/SMC/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/DRIVERS/EIC/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/DRIVERS/FLASHC/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/DRIVERS/GPIO/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/DRIVERS/INTC/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/DRIVERS/PDCA/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/DRIVERS/PM/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/DRIVERS/RTC/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/DRIVERS/SPI/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/DRIVERS/TC/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/DRIVERS/USART/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/SERVICES/DELAY/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/SERVICES/LWIP/lwip-1.3.2/src/include/ipv4/lwip/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/SERVICES/LWIP/lwip-1.3.2/src/include/lwip/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/SERVICES/LWIP/lwip-1.3.2/src/include/netif/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/SERVICES/LWIP/lwip-port-1.3.2/HD/if/include/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/SERVICES/LWIP/lwip-port-1.3.2/HD/if/include/arch/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/SERVICES/LWIP/lwip-port-1.3.2/HD/if/include/netif/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/SERVICES/MEMORY/CTRL_ACCESS/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/UTILS/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/UTILS/DEBUG/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/UTILS/LIBS/NEWLIB_ADDONS/INCLUDE/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifiHD/src/SOFTWARE_FRAMEWORK/UTILS/PREPROCESSOR/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifi_dnld/src/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifi_dnld/src/CONFIG/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifi_dnld/src/SOFTWARE_FRAMEWORK/BOARDS/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifi_dnld/src/SOFTWARE_FRAMEWORK/BOARDS/ARDUINO/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifi_dnld/src/SOFTWARE_FRAMEWORK/BOARDS/EVK1105/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifi_dnld/src/SOFTWARE_FRAMEWORK/COMPONENTS/MEMORY/DATA_FLASH/AT45DBX/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifi_dnld/src/SOFTWARE_FRAMEWORK/DRIVERS/FLASHC/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifi_dnld/src/SOFTWARE_FRAMEWORK/DRIVERS/GPIO/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifi_dnld/src/SOFTWARE_FRAMEWORK/DRIVERS/INTC/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifi_dnld/src/SOFTWARE_FRAMEWORK/DRIVERS/PM/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifi_dnld/src/SOFTWARE_FRAMEWORK/DRIVERS/SPI/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifi_dnld/src/SOFTWARE_FRAMEWORK/DRIVERS/USART/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifi_dnld/src/SOFTWARE_FRAMEWORK/SERVICES/MEMORY/CTRL_ACCESS/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifi_dnld/src/SOFTWARE_FRAMEWORK/UTILS/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifi_dnld/src/SOFTWARE_FRAMEWORK/UTILS/DEBUG/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifi_dnld/src/SOFTWARE_FRAMEWORK/UTILS/LIBS/NEWLIB_ADDONS/INCLUDE/",
        //ARDUINO_DIR+"/firmwares/wifishield/wifi_dnld/src/SOFTWARE_FRAMEWORK/UTILS/PREPROCESSOR/",

    ]

    //    Properties {
    //        condition: qbs.buildVariant === "debug"
    //        cpp.defines: outer.concat(["DEBUG=1"])
    //        cpp.debugInformation: true
    //        cpp.optimization: "none"
    //    }

    //    Properties {
    //        condition: qbs.buildVariant === "release"
    //        cpp.defines: outer.concat(["DEBUG=0"])
    //        cpp.debugInformation: false
    //        cpp.optimization: "fast"
    //        //Виды оптимизаций: "none", "fast", "small"
    //    }

    //    cpp.libraryPaths: [
    //        Home + "/Middlewares/ST/STemWin/Lib",
    //        STemWin + "/STemWin_Addons",
    //    ]
    //    cpp.staticLibraries: [
    //        ":STemWin540_CM7_OS_GCC_ot.a",
    //        ":STM32746G_Discovery_STemWin_Addons_GCC.a",
    //    ]

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
            //var AVR_GCC_Path =     "C:/Program Files (x86)/Arduino/hardware/tools/avr/bin/"
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
                        "-P", "COM10",
                        "-b", "115200",
                        "-U", "flash:w:"+output.filePath+":i"
                    ]

            var cmdSize = new Command(product.AVR_GCC_Path + "avr-size.exe", argsSize)
            var cmdObjcopyHex = new Command(product.AVR_GCC_Path + "avr-objcopy.exe", argsObjcopyHex)
            var cmdObjcopyBin = new Command(product.AVR_GCC_Path + "avr-objcopy.exe", argsObjcopyBin)

            /*
                Если не работает то скопировать avrdude.conf из
                C:\Program Files (x86)\Arduino\hardware\arduino\avr\bootloaders\gemma
                в
                AVR_GCC_Path
                */
            var cmdFlash = new Command(product.AVR_GCC_Path + "avrdude.exe", argsFlashing);

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
                        //cmdFlash // Закомметировать если не нужно шить
                    ]
        }
    }
}




////Подключаем стандартные библиотеки в стиле QML
////Основные концепции языка:
////Проект (Project), Продукт (Product), Артефакт (Artifact), Модуль (Module), Правило (Rule), Группа(Group), Зависимость (Depends), Тег (Tag).
////Продукт — это аналог pro или vcproj, т. е. одна цель для сборки.
////Проект — это набор ваших продуктов вместе с зависимостями, воспринимаемый системой сборки как одно целое. Один проект — один граф сборки.
////Тег — система классификации файлов. Например «*.cpp» => «cpp»
////Правило — Преобразование файлов проекта, отмеченных определенными тегами. Генерирует другие файлы, называемые Артефактами.
////Как правило, это компиляторы или другие системы сборки.
////Артефакт — файл, над который является выходным для правила (и возможно, входным для другиx правил). Это обычно «obj», «exe» файлы.
////У многих QML-объектов есть свойство condition, которое отвечает за то, будет собираться он или нет. А если нам необходимо разделить так файлы?
////Для этого их можно объединить в группу (Group)
////Rule умеет срабатывать на каждый файл, попадающий под что-то. Может срабатывать по разу на каждый фаил (например, для вызова компилятора), а может один раз на все (линкер).
////Transformer предназначен для срабатывания только на один фаил, с заранее определенным именем. Например, прошивальщик или какой-нибудь хитрый скрипт.
////флаг multiplex, который говорит о том, что это правило обрабатывает сразу все файлы данного типа скопом.

//import qbs
//import qbs.FileInfo
//import qbs.ModUtils
//import qbs.Probes

//Product {
//    consoleApplication: true

//    cpp.debugInformation: true
//    cpp.enableExceptions: false // passes -fno-exceptions
//    cpp.executableSuffix: ".elf"
//    cpp.optimization: "small" // passes -Os
//    cpp.positionIndependentCode: false
//    cpp.warningLevel: "none" // passes -w


//    property string ARDUINO_CORE: "C:/Program Files (x86)/Arduino/hardware/arduino/avr/cores/arduino"
//    property string ARDUINO_DIR: "C:/Program Files (x86)/Arduino/hardware/arduino/avr"
//    property string ARDUINO_LIB_DEF: "C:/Program Files (x86)/Arduino/hardware/arduino/avr/libraries"

//    property string ARDUINO_LIB_USER: "C:/Users/X-Ray/Documents/Arduino/libraries"

//    property string ARDUINO_MCU: "atmega328p"

//    property string AVR_GCC_Path:"C:/Program Files (x86)/Arduino/hardware/tools/avr/bin/"

//    type: [ // call Rules
//        "application",
//        "hex",
//    ]


//    Group {
//        name: "App"
//        prefix: path
//        files: [
//            "/**/*.c",
//            "/**/*.cpp",
//            "/**/*.h",
//            "/**/*.hpp",
//        ]
//        excludeFiles: [
//        ]
//    }

////    Group {
////        name: "User Libraries"
////        prefix: ARDUINO_LIB_USER
////        files: [
////            "/LiquidCrystal/src/*.cpp",
////            "/LiquidCrystal/src/*.h",
////        ]
////        excludeFiles: [
////        ]
////    }

////    Group {
////        name: "Core Libraries"
////        prefix: ARDUINO_LIB_DEF
////        files: [
////            "/**/*.c",
////            "/**/*.cpp",
////            "/**/*.h",
////        ]
////        excludeFiles: []
////    }

////    Group {
////        name: "Core"
////        prefix: ARDUINO_CORE
////        files: [
////            "/**/*.c",
////            "/**/*.cpp",
////            "/**/*.h",
////            "/**/*.S",
////        ]
////        excludeFiles: [
////            "/**/Tone.cpp",//       redefine ISR`s
////            "/**/WInterrupts.c"//   redefine ISR`s
////        ]
////    }

//    Depends { name:"cpp" }
//    cpp.cxxLanguageVersion: "c++20"
//    cpp.defines: [
//        //"ARDUINO=10813",
//        "ARDUINO_ARCH_AVR",
//        "ARDUINO_AVR_UNO",
//        "ARDUINO_MAIN",
//        "F_CPU=16000000L",
//        "__AVR_ATmega328P__",
//        "__PROG_TYPES_COMPAT__",
//    ]
//    cpp.cxxFlags: [
//        "-fno-rtti",
//        "-fno-threadsafe-statics",
//        "-fpermissive",
//    ]
//    cpp.cFlags: [ "-std=gnu11" ]
//    cpp.commonCompilerFlags: [
//        "-Wall",
//        "-fdata-sections",
//        "-ffunction-sections",
//        "-fno-asynchronous-unwind-tables",
//        "-mmcu=" + ARDUINO_MCU,
//        //"-funsigned-char",
//    ]

//    cpp.driverLinkerFlags:[
//        "--data-sections",
//        "--warn-all",
//        "-mmcu=" + ARDUINO_MCU,
//        "-flto",
//        "-fuse-linker-plugin",
//    ]

//    cpp.linkerFlags:[
//        "-flto",
//        "--gc-sections",//
//        "--strip-all",//
//        "-lm",
//        "--start-group",
//        "-lgcc",
//        "-lm",
//        "-lc",
////        "-latmega328p",
//        "--end-group",
//    ]

//    cpp.includePaths: [
//        ARDUINO_DIR + "/cores/arduino/",
//        ARDUINO_DIR + "/libraries/",
//        ARDUINO_DIR + "/variants/standard/",

////        ARDUINO_LIB_DEF + "/SoftwareSerial/src/",
////        ARDUINO_LIB_DEF + "/Spi/src/",
////        ARDUINO_LIB_DEF + "/Wire/src/",

////        ARDUINO_LIB_USER + "/LiquidCrystal/src/",

//        path,
//    ]


//    Rule
//    {
//        inputs: ["application"]
//        Artifact
//        {
//            filePath: project.buildDirectory + product.name + ".hex"
//            fileTags: "hex"
//        }

//        prepare:
//        {
//            var argsSize = [
//                        input.filePath,
//                        "--mcu=" + product.ARDUINO_MCU,
//                        "-C",
//                        "--format=avr"
//                    ]

//            var argsObjcopyHex = [
//                        "-O", "ihex",
//                        "-j", ".text",
//                        "-j", ".data",
//                        input.filePath,
//                        output.filePath
//                    ]

//            var argsObjcopyBin = [
//                        "-O", "binary",
//                        "-S", "-g",
//                        input.filePath,
//                        project.buildDirectory + product.name + ".bin"
//                    ]

//            var argsFlashing = [// насиройки для прошивки
//                                "-c", "arduino",
//                                "-p", "m328p",
//                                "-P", "COM10",
//                                "-b", "115200",
//                                "-U", "flash:w:" + output.filePath + ":i"
//                    ]

//            var cmdSize = new Command(product.AVR_GCC_Path + "avr-size.exe", argsSize)
//            var cmdObjcopyHex = new Command(product.AVR_GCC_Path + "avr-objcopy.exe", argsObjcopyHex)
//            var cmdObjcopyBin = new Command(product.AVR_GCC_Path + "avr-objcopy.exe", argsObjcopyBin)

//            /*
//                Если не работает то скопировать avrdude.conf из
//                C:/Program Files (x86)/Arduino/hardware/arduino/avr/bootloaders/gemma
//                в
//                AVR_GCC_Path
//            */
//            var cmdFlash = new Command(product.AVR_GCC_Path + "avrdude.exe", argsFlashing);

//            cmdSize.description = "Size of sections:"
//            cmdSize.highlight = "filegen"

//            cmdObjcopyHex.description = "convert to hex..."
//            cmdObjcopyHex.highlight = "filegen"

//            cmdObjcopyBin.description = "convert to bin..."
//            cmdObjcopyBin.highlight = "filegen"

//            cmdFlash.description = "download firmware to uC..."
//            cmdFlash.highlight = "filegen"
//            return [
//                        cmdSize,
//                        cmdObjcopyHex,
//                        cmdObjcopyBin,
//                        cmdFlash // Закомметировать если не нужно шить
//                    ]
//        }
//    }
//}

