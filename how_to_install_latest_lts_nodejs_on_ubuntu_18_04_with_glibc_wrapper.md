# How to install latest LTS Node.js on Ubuntu 18.04 with a GLIBC wrapper

This guide is specifically for Ubuntu 18.04.
It is based on [install-nodejs-local.sh](install-nodejs-local.sh), but rewritten so you can run each command step by step in your terminal.

## 1) Prerequisites

First, make sure the GLIBC 2.33 loader exists.

```bash
ls -l /opt/glibc-2.33/lib/ld-linux-x86-64.so.2
```

If you see `No such file`, prepare your GLIBC path first.

You also need `patchelf` and `curl` (or `wget`).

```bash
command -v patchelf
command -v curl || command -v wget
```

## 2) Set variables

Set the following variables in your current shell.

```bash
GLIBC_PATH="/opt/glibc-2.33/lib"
GLIBC_LINKER="/opt/glibc-2.33/lib/ld-linux-x86-64.so.2"
LOCAL_DIR="$HOME/.local"
NODE_DIST_BASE="https://nodejs.org/dist"
```

## 3) Get the latest LTS version

```bash
NODE_VERSION=$(curl -fsSL https://nodejs.org/dist/index.json \
  | python3 -c "import sys, json; data=json.load(sys.stdin); lts=[x for x in data if x.get('lts')]; print(lts[0]['version'] if lts else '')")
```

If the value is empty, set a fallback version manually.

```bash
[ -z "$NODE_VERSION" ] && NODE_VERSION="v22.15.0"
echo "$NODE_VERSION"
```

## 4) Build download and install paths

```bash
ARCH="x64"
TARBALL="node-${NODE_VERSION}-linux-${ARCH}.tar.xz"
DOWNLOAD_URL="${NODE_DIST_BASE}/${NODE_VERSION}/${TARBALL}"
INSTALL_DIR="${LOCAL_DIR}/share/nodejs-${NODE_VERSION}"
mkdir -p "$INSTALL_DIR"
```

## 5) Download the Node.js archive

```bash
TMPFILE="$(mktemp --suffix=.tar.xz)"
curl -fsSL --progress-bar "$DOWNLOAD_URL" -o "$TMPFILE"
# If curl is not available:
# wget -q --show-progress "$DOWNLOAD_URL" -O "$TMPFILE"
```

## 6) Extract

```bash
tar -xf "$TMPFILE" -C "$INSTALL_DIR" --strip-components=1
rm -f "$TMPFILE"
```

## 7) Patch binaries with GLIBC interpreter and RPATH

```bash
PATCHELF="$(which patchelf 2>/dev/null || echo /usr/bin/patchelf)"
RPATH="${GLIBC_PATH}:/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu"
```

Run the loop below as is.

```bash
for BIN in "$INSTALL_DIR/bin/node" "$INSTALL_DIR/bin/npm" "$INSTALL_DIR/bin/npx"; do
  REAL_BIN=$(readlink -f "$BIN" 2>/dev/null || echo "")
  [ -z "$REAL_BIN" ] && continue
  [ ! -x "$REAL_BIN" ] && continue
  if file "$REAL_BIN" | grep -q ELF; then
    "$PATCHELF" --set-rpath "$RPATH" "$REAL_BIN"
    "$PATCHELF" --set-interpreter "$GLIBC_LINKER" "$REAL_BIN"
  fi
done
```

## 8) Prepare local alternatives directories

```bash
mkdir -p "$HOME/.local/var/lib/alternatives" \
         "$HOME/.local/etc/alternatives" \
         "$HOME/.local/bin"
```

```bash
ALT_CMD="update-alternatives --altdir $HOME/.local/etc/alternatives --admindir $HOME/.local/var/lib/alternatives"
```

```bash
$ALT_CMD --install "$HOME/.local/bin/node" node "$INSTALL_DIR/bin/node" 100
$ALT_CMD --install "$HOME/.local/bin/npm"  npm  "$INSTALL_DIR/bin/npm"  100
$ALT_CMD --install "$HOME/.local/bin/npx"  npx  "$INSTALL_DIR/bin/npx"  100
```

## 9) Key fix: apply a node wrapper script

Problem:
Directly running `~/.local/bin/node` may pick up system libc first and fail with `GLIBC_2.28 not found`.

Solution:
Move the existing `node` entry to a versioned filename, then recreate `node` as a GLIBC loader wrapper script.

```bash
NODE_WRAPPER="$HOME/.local/bin/node"
NODE_VERSIONED="$HOME/.local/bin/node-${NODE_VERSION}"
```

```bash
[ -e "$NODE_VERSIONED" ] || [ -L "$NODE_VERSIONED" ] && rm -f "$NODE_VERSIONED"
[ -e "$NODE_WRAPPER" ] || [ -L "$NODE_WRAPPER" ] && mv "$NODE_WRAPPER" "$NODE_VERSIONED"
```

If `NODE_WRAPPER` did not exist, create the symlink directly.

```bash
[ -e "$NODE_WRAPPER" ] || [ -L "$NODE_WRAPPER" ] || ln -s "$INSTALL_DIR/bin/node" "$NODE_VERSIONED"
```

Now create the `node` wrapper script.

```bash
cat > "$NODE_WRAPPER" <<EOF
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

/opt/glibc-2.33/lib/ld-linux-x86-64.so.2 \
  --library-path /opt/glibc-2.33/lib \
  "$SCRIPT_DIR/node-${NODE_VERSION}" "$@"
EOF
```

```bash
chmod +x "$NODE_WRAPPER"
```

## 10) Verify PATH and runtime

```bash
export PATH="$HOME/.local/bin:$PATH"
```

```bash
$HOME/.local/bin/node --version
$HOME/.local/bin/npm --version
$HOME/.local/bin/npx --version
```

If needed, add PATH to your shell startup file (for example, `~/.bashrc`).
