```
$ vi .profile 
```

하기 문구 추가
```
$ mkdir -p ~/.local/var/lib/alternatives ~/.local/etc/alternatives ~/.local/bin
$ alias update-my-alternatives='update-alternatives --altdir ~/.local/etc/alternatives --admindir ~/.local/var/lib/alternatives'
```

```
$ update-my-alternatives --install $HOME/.local/bin/cmake cmake /usr/local/bin/cmake 100

$ which cmake
/home/{username}/.local/bin/cmake

$ cmake --version
cmake version 3.24.2

CMake suite maintained and supported by Kitware (kitware.com/cmake).
```
cmake 를 기존으로 변경 원하는 경우
```
$ update-my-alternatives --install $HOME/.local/bin/cmake cmake /usr/bin/cmake 100
```
