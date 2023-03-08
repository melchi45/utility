# paho-library-cross-compile

## Environment settings
First, you have to set the cross compile binary directory.
```
export WN5_TOOLCHAIN_ROOT=/opt/toolchain/other/gcc-5.2.0-cortex-a7/arm-cortex_a7-linux-gnueabihf/armv7-cortex_A7-linux-gnueabihf/bin
```

## Clone the paho c source library from github
You can clone paho c library code from github. and move to build target directory.
```
git clone https://github.com/eclipse/paho.mqtt.c paho/c
cd paho/c
```

# make Cross compile toolchain file for cmake
You should be make the toolchain file for cmake on cross platform. You have to make the toolchain file for cmake with this command.
```
vi toolchain.wn5.cmake
```
And, you add this cmake script for toolchain. The WN5_TOOLCHAIN_ROOT is path of toolchain. The WN5_HOST_NAME is compiler name for cross platform.
Actually, toolchain information just need to certainly definition like this: CMAKE_C_COMPILER, CMAKE_CXX_COMPILER, CMAKE_LINKER, CMAKE_RANLIB.
But, This script was added the optional setting likes CMAKE_AR option. 

```
set(WN5_TOOLCHAIN_ROOT "/opt/toolchain/other/gcc-5.2.0-cortex-a7/arm-cortex_a7-linux-gnueabihf/armv7-cortex_A7-linux-gnueabihf/bin")
set(WN5_HOST_NAME "armv7-cortex_A7-linux-gnueabihf")

if(NOT DEFINED ENV{WN5_TOOLCHAIN_ROOT})
        message("WN5 toolchain path: ${WN5_TOOLCHAIN_ROOT}")
        find_path(WN5_TOOLCHAIN_ROOT "${WN5_HOST_NAME}-gcc")
else()
        set(WN5_TOOLCHAIN_ROOT "$ENV{WN5_TOOLCHAIN_ROOT}")
        #set(CV5_TOOLCHAIN_ROOT "/usr/local/cortex-a76-2022.03-gcc11.2-linux5.15/bin/aarch64-linux-gnu-")
endif()

SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

set(CMAKE_C_COMPILER   "${WN5_TOOLCHAIN_ROOT}/${WN5_HOST_NAME}-gcc" )
set(CMAKE_CXX_COMPILER "${WN5_TOOLCHAIN_ROOT}/${WN5_HOST_NAME}-g++" )
set(CMAKE_LINKER       "${WN5_TOOLCHAIN_ROOT}/${WN5_HOST_NAME}-ld" )
set(CMAKE_NM           "${WN5_TOOLCHAIN_ROOT}/${WN5_HOST_NAME}-nm" )
set(CMAKE_OBJCOPY      "${WN5_TOOLCHAIN_ROOT}/${WN5_HOST_NAME}-objcopy" )
set(CMAKE_OBJDUMP      "${WN5_TOOLCHAIN_ROOT}/${WN5_HOST_NAME}-objdump" )
set(CMAKE_RANLIB       "${WN5_TOOLCHAIN_ROOT}/${WN5_HOST_NAME}-ranlib" )
set(CMAKE_AR           "${WN5_TOOLCHAIN_ROOT}/${WN5_HOST_NAME}-ar" )
```


Additionally, If you need to build with the openssl library for paho c library, you should add openssl path for cross platform.
