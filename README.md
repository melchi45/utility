# paho-library-cross-compile

## Environment settings
First, you have to set the cross compile binary directory.
```
$ export WN5_TOOLCHAIN_ROOT=/opt/toolchain/other/gcc-5.2.0-cortex-a7/arm-cortex_a7-linux-gnueabihf/armv7-cortex_A7-linux-gnueabihf/bin
```

## Clone the paho c source library from github
You can clone paho c library code from github. and move to build target directory.
```
$ git clone https://github.com/eclipse/paho.mqtt.c paho/c
$ cd paho/c
```

# make Cross compile toolchain file for cmake
You should be make the toolchain file for cmake on cross platform. You have to make the toolchain file for cmake with this command.
```
$ vi toolchain.wn5.cmake
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

## Make cmake build environment
The CMake build has very variable options. But, This file describes only the options required for the paho library build. If you do not know the options, search on google.

This command makes the paho build environment with cross platform toolchain file.
```
$ export OUT_PATH=./install
$ cmake . -B wn5 -G "Unix Makefiles" \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${OUT_PATH} \
  -DCMAKE_TOOLCHAIN_FILE=toolchain.wn5.cmake
```

And, you can build source code files with above build environments.
```
cmake --build wn5 --config Release --target install
```

## With openssl library
Paho c library already defined  security function  with openssl on  source code. You just adding the PAHO_WITH_SSL option for cmake.
In this case, you have to add the CMAKE_PREFIX_PATH path for cross platform environment. 

## Shared library
Also, Paho c library already have shared library option. If you need the PAHO_BUILD_SHARED to cmake environment command.

## Real build command in my cased.
Finally, In my cased use the this command.
```
$ cmake . -B wn5 -G "Unix Makefiles" \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${OUT_PATH} \
  -DCMAKE_TOOLCHAIN_FILE=toolchain.wn5.cmake \
  -DPAHO_BUILD_SHARED=TRUE \
  -DPAHO_WITH_SSL=TRUE \
  -DCMAKE_PREFIX_PATH=/home/youngho/workspace/TID600R_VWF/wn5/bsp/rootfilesystem/nfsroot/wn5/usr
$ cmake --build wn5 --config Release --target install
```






