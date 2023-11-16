

```
version=3.28
build=0-rc5limit=3.20
# don't modify from here
limit=3.20
result=$(echo "$version >= $limit" | bc -l)
os=$([ "$result" == 1 ] && echo "linux" || echo "Linux")
mkdir ~/temp
cd ~/temp
wget https://cmake.org/files/v$version/cmake-$version.$build-$os-x86_64.sh
mkdir -p ~/.local
sh cmake-$version.$build-$os-x86_64.sh --prefix=${HOME}/.local --include-subdir=${HOME}/.local --exclude-subdir=${HOME}/.local
```
