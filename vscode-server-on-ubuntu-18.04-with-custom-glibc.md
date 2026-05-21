# Running VSCode Server on Ubuntu 18.04 with Custom glibc

## Problem

Ubuntu 18.04 ships with **glibc 2.27** by default. Recent versions of VSCode Insiders (1.100+)
bundle a `node` binary that requires **GLIBC_2.28** or higher. When the bundled node tries to
start, the following error is printed and the terminal becomes unusable:

```
/path/to/.vscode-server-insiders/.../server/node:
    /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.28' not found
    (required by .../server/node)
```

## Solution Overview

VSCode Server's startup script (`bin/code-server-insiders`) has built-in support for patching
the bundled `node` binary with a custom glibc at launch time, using
[patchelf](https://github.com/NixOS/patchelf). By setting three environment variables, the
server automatically rewrites the ELF interpreter and rpath of the `node` binary before
executing it.

## Prerequisites

### 1. Install patchelf

```bash
sudo apt-get install patchelf
```

Verify:

```bash
which patchelf
# /usr/bin/patchelf
```

### 2. Build and install glibc 2.33 into /opt/glibc-2.33

> **Note:** Do **not** replace the system glibc. Install it to a separate prefix such as
> `/opt/glibc-2.33` to avoid breaking the OS.

```bash
# Install build dependencies
sudo apt-get install -y gawk bison

# Download glibc 2.33 source
wget https://ftp.gnu.org/gnu/glibc/glibc-2.33.tar.xz
tar -xf glibc-2.33.tar.xz

# Build out-of-tree (required by glibc)
mkdir glibc-2.33-build && cd glibc-2.33-build
../glibc-2.33/configure \
    --prefix=/opt/glibc-2.33 \
    --enable-multi-arch

make -j$(nproc)
sudo make install
```

After installation the directory should contain:

```
/opt/glibc-2.33/lib/
    ld-linux-x86-64.so.2   ← dynamic linker / ELF interpreter
    libc.so.6
    libm.so.6
    libpthread.so.0
    ...
```

## Configuration

### Set environment variables in /etc/environment

Append the following lines to `/etc/environment` so that the variables are available
system-wide (and therefore visible to the SSH daemon that starts the VSCode server):

```
VSCODE_SERVER_CUSTOM_GLIBC_LINKER=/opt/glibc-2.33/lib/ld-linux-x86-64.so.2
VSCODE_SERVER_CUSTOM_GLIBC_PATH=/opt/glibc-2.33/lib:/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu
VSCODE_SERVER_PATCHELF_PATH=/usr/bin/patchelf
```

| Variable | Purpose |
|---|---|
| `VSCODE_SERVER_CUSTOM_GLIBC_LINKER` | Path to the ELF interpreter (`ld-linux-x86-64.so.2`) inside the custom glibc installation. Written into the `PT_INTERP` segment of the node binary by patchelf. |
| `VSCODE_SERVER_CUSTOM_GLIBC_PATH` | Colon-separated rpath list. The custom glibc directory is listed first so it takes priority; the system library directories follow as fallbacks for other shared libraries (e.g. `libstdc++`). |
| `VSCODE_SERVER_PATCHELF_PATH` | Absolute path to the `patchelf` executable. |

## How It Works

VSCode Server's `bin/code-server-insiders` script contains the following logic:

```sh
if [ -n "$VSCODE_SERVER_CUSTOM_GLIBC_LINKER" ] && \
   [ -n "$VSCODE_SERVER_CUSTOM_GLIBC_PATH" ] && \
   [ -n "$VSCODE_SERVER_PATCHELF_PATH" ]; then
    "$VSCODE_SERVER_PATCHELF_PATH" --set-rpath "$VSCODE_SERVER_CUSTOM_GLIBC_PATH" "$ROOT/node"
    "$VSCODE_SERVER_PATCHELF_PATH" --set-interpreter "$VSCODE_SERVER_CUSTOM_GLIBC_LINKER" "$ROOT/node"
fi

"$ROOT/node" ${INSPECT:-} "$ROOT/out/server-main.js" "$@"
```

When all three variables are set:

1. **`--set-rpath`** rewrites the `DT_RPATH`/`DT_RUNPATH` entry of the node ELF binary so that
   `/opt/glibc-2.33/lib` is searched first when loading shared libraries.
2. **`--set-interpreter`** replaces the ELF interpreter (`PT_INTERP`) with the custom
   `ld-linux-x86-64.so.2`, so the OS loader uses the newer glibc instead of the system one.
3. The patched `node` binary is then executed normally.

> **Note:** The patch is applied **in-place** to the `node` binary each time the server starts.
> This is safe because the script is idempotent — patchelf overwrites the same fields on every
> run.

## Verification

After reconnecting to the remote host from VSCode, open a new terminal and confirm node runs:

```bash
# The bundled node path varies by VSCode commit hash
~/.vscode-server-insiders/cli/servers/Insiders-<commit>/server/node --version
# v22.x.x
```

You should also see the following lines printed in the VSCode server startup log (Remote
Output channel):

```
Patching glibc from /opt/glibc-2.33/lib:... with /usr/bin/patchelf...
Patching linker from /opt/glibc-2.33/lib/ld-linux-x86-64.so.2 with /usr/bin/patchelf...
Patching complete.
```

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---|---|---|
| `GLIBC_2.28' not found` still appears | `/etc/environment` not sourced by the SSH session | Add the exports to `~/.profile` or `/etc/profile.d/vscode-glibc.sh` as well |
| `patchelf: command not found` | patchelf not installed or wrong path | Run `which patchelf` and update `VSCODE_SERVER_PATCHELF_PATH` accordingly |
| VSCode fails to connect after patching | node binary corrupted by patchelf | Delete the server directory and let VSCode re-download it: `rm -rf ~/.vscode-server-insiders/cli/servers/Insiders-<commit>` |
| `libstdc++.so.6` errors after patching | rpath does not include system lib paths | Ensure `VSCODE_SERVER_CUSTOM_GLIBC_PATH` includes `:/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu` |

## References

- [patchelf — NixOS/patchelf](https://github.com/NixOS/patchelf)
- [GNU C Library (glibc) releases](https://ftp.gnu.org/gnu/glibc/)
- [VSCode Remote Development — troubleshooting](https://code.visualstudio.com/docs/remote/troubleshooting)
- Related VSCode issue: [patchelf rpath before interpreter](https://github.com/NixOS/patchelf/issues/524)
