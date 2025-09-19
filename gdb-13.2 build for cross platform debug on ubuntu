### Building GDB 13.2 with AArch64 and GMP/MPFR/MPC Support on Ubuntu 18.04
## 1. Install required dependencies
```bash
sudo apt update
sudo apt install build-essential texinfo libncurses-dev python3-dev zlib1g-dev \
                 libgmp-dev libmpfr-dev libmpc-dev
```
These libraries enable advanced math support and expression parsing in GDB.

## 2. Download and extract GDB source
```bash
wget https://ftp.gnu.org/gnu/gdb/gdb-13.2.tar.gz
tar -xvzf gdb-13.2.tar.gz
cd gdb-13.2
```
## 3. Configure and build GDB with multiarch support
```bash
./configure --prefix=/opt/gdb-13.2 --enable-targets=all \
            --with-gmp --with-mpfr --with-mpc
make -j$(nproc)
sudo make install
The --enable-targets=all flag ensures support for multiple architectures including AArch64.
```
## 4. Verify installation
```bash
/opt/gdb-13.2/bin/gdb --version
ldd /opt/gdb-13.2/bin/gdb | grep -E 'gmp|mpfr|mpc'
```

### 🖥️ VS Code Configuration for Remote AArch64 Debugging
Create or edit .vscode/launch.json in your project folder:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Remote Debug (AArch64)",
      "type": "cppdbg",
      "request": "launch",
      "program": "${workspaceFolder}/myapp",  // Local binary with debug symbols
      "miDebuggerPath": "/opt/gdb-13.2/bin/gdb",  // Path to GDB 13.2
      "miDebuggerServerAddress": "192.168.214.34:1234",  // Remote gdbserver address
      "cwd": "${workspaceFolder}",
      "setupCommands": [
        {
          "description": "Set architecture to AArch64",
          "text": "set architecture aarch64",
          "ignoreFailures": false
        },
        {
          "description": "Load symbol file",
          "text": "file ${workspaceFolder}/myapp",
          "ignoreFailures": false
        }
      ],
      "stopAtEntry": true,
      "externalConsole": false
    }
  ]
}
```

### 🌐 Running gdbserver on the Remote AArch64 Device
## 1. Transfer the target binary
Copy the debug-enabled binary (myapp) to the remote device:

```bash
scp myapp user@remote-device:/home/user/
```

## 2. Launch gdbserver on the remote device
```bash
gdbserver :1234 ./myapp
```
Or attach to a running process:

```bash
gdbserver :1234 --attach <PID>
```

## 3. Optional: Use SSH port forwarding
If direct access to port 1234 is blocked:

```bash
ssh -L 1234:localhost:1234 user@remote-device
```
