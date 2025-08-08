### download cmake 4.1.0 [https://cmake.org/download/]



## cmake download and install script
```
#/bin/bash

version=4.1
build=.0-rc4
# don't modify from here
limit=4.1
result=$(echo "$version >= $limit" | bc -l)
os=$([ "$result" == 1 ] && echo "linux" || echo "Linux")
mkdir ~/temp
cd ~/temp
wget https://cmake.org/files/v$version/cmake-$version$build-$os-x86_64.sh
mkdir -p ~/.local
sh cmake-$version$build-$os-x86_64.sh --prefix=${HOME}/.local --include-subdir=${HOME}/.local --exclude-subdir=${HOME}/.local
```
## alternatives comtom path for each user

### The update-my-alternatives command makes new custom cmake command to ~/.local/bin path
```
$ sudo update-alternatives --install /usr/bin/cmake cmake ~/.local/bin/cmake 100
$ update-alternatives --query cmake
# update-alternatives --get-selections
```

### check your cmake command link to ~/.local/bin/cmake
```
$ which cmake
```

### check cmake version using --version option.
```
$ cmake --version
```

## if you want, you can revert to original command
```
$ sudo update-alternatives --set cmake /usr/bin/cmake
```
