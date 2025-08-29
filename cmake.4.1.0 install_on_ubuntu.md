### download cmake 4.1.0 [https://cmake.org/download/]



## cmake download and install script

```
# vi install_cmake_4.1.sh
#/bin/bash

version=4.1
build=.1
# don't modify from here
limit=4.1
result=$(echo "$version >= $limit" | bc -l)
os=$([ "$result" == 1 ] && echo "linux" || echo "Linux")
mkdir ~/temp
cd ~/temp
wget https://cmake.org/files/v$version/cmake-$version$build-$os-x86_64.sh
mkdir -p ~/.local/cmake-$version
sh cmake-$version$build-$os-x86_64.sh --prefix=${HOME}/.local/cmake-$version --include-subdir=${HOME}/.local/cmake-$version --exclude-subdir=${HOME}/.local/cmake-$version
# chmod +x install_cmake_4.1.sh
```
## alternatives comtom path for each user

### The update-my-alternatives command makes new custom cmake command to ~/.local/bin path
```
$ sudo update-my-alternatives --install $HOME/.local/bin/cmake cmake $HOME/.local/cmake-4.1/bin/cmake 101
$ update-my-alternatives --query cmake
# update-my-alternatives --get-selections
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
$ sudo update-my-alternatives --set cmake /usr/bin/cmake
```
