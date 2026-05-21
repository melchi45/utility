#!/usr/bin/env bash
# Install latest Node.js LTS to $HOME/.local with /opt/glibc-2.33 patching
# Based on update-my-alternatives pattern

set -e

GLIBC_PATH="/opt/glibc-2.33/lib"
GLIBC_LINKER="/opt/glibc-2.33/lib/ld-linux-x86-64.so.2"
PATCHELF="$(which patchelf 2>/dev/null || echo /usr/bin/patchelf)"
LOCAL_DIR="$HOME/.local"
LOG="$HOME/.local/nodejs-install.log"

exec > >(tee -a "$LOG") 2>&1
echo "=== Node.js local install start: $(date) ==="

# ── 1. Prerequisites check ───────────────────────────────────────────────────
echo "[1/7] Checking prerequisites..."

if [ ! -f "$GLIBC_LINKER" ]; then
    echo "ERROR: $GLIBC_LINKER not found. Aborting."
    exit 1
fi
echo "  glibc-2.33 linker : $GLIBC_LINKER  OK"

if ! command -v "$PATCHELF" &>/dev/null; then
    echo "ERROR: patchelf not found at $PATCHELF"
    echo "  Install with: sudo apt-get install patchelf"
    exit 1
fi
echo "  patchelf          : $PATCHELF  OK"

if ! command -v curl &>/dev/null && ! command -v wget &>/dev/null; then
    echo "ERROR: neither curl nor wget found."
    exit 1
fi

# ── 2. Resolve latest Node.js LTS version ────────────────────────────────────
echo "[2/7] Resolving latest Node.js LTS version..."
NODE_DIST_BASE="https://nodejs.org/dist"

if command -v curl &>/dev/null; then
    LATEST_LTS=$(curl -fsSL https://nodejs.org/dist/index.json \
        | grep -o '"version":"v[^"]*"' \
        | grep -v "nightly\|rc\|next" \
        | head -40 \
        | while IFS= read -r line; do
              ver=$(echo "$line" | grep -o 'v[0-9]*\.[0-9]*\.[0-9]*')
              # fetch lts field — use index.json lts check approach
              echo "$ver"
          done \
        | head -1)
    # Better: use release schedule endpoint for LTS
    LATEST_LTS=$(curl -fsSL https://nodejs.org/dist/index.json \
        | python3 -c "
import sys, json
data = json.load(sys.stdin)
lts = [x for x in data if x.get('lts')]
if lts:
    print(lts[0]['version'])
" 2>/dev/null)
fi

if [ -z "$LATEST_LTS" ]; then
    # Fallback: Node.js 22 LTS (Iron)
    LATEST_LTS="v22.15.0"
    echo "  Could not resolve dynamically, using fallback: $LATEST_LTS"
else
    echo "  Latest LTS: $LATEST_LTS"
fi

NODE_VERSION="$LATEST_LTS"
ARCH="x64"
TARBALL="node-${NODE_VERSION}-linux-${ARCH}.tar.xz"
DOWNLOAD_URL="${NODE_DIST_BASE}/${NODE_VERSION}/${TARBALL}"
INSTALL_DIR="${LOCAL_DIR}/share/nodejs-${NODE_VERSION}"

# ── 3. Download ───────────────────────────────────────────────────────────────
echo "[3/7] Downloading $TARBALL ..."
mkdir -p "$INSTALL_DIR"
TMPFILE="$(mktemp --suffix=.tar.xz)"

if command -v curl &>/dev/null; then
    curl -fsSL --progress-bar "$DOWNLOAD_URL" -o "$TMPFILE"
else
    wget -q --show-progress "$DOWNLOAD_URL" -O "$TMPFILE"
fi
echo "  Downloaded to $TMPFILE"

# ── 4. Extract ────────────────────────────────────────────────────────────────
echo "[4/7] Extracting to $INSTALL_DIR ..."
tar -xf "$TMPFILE" -C "$INSTALL_DIR" --strip-components=1
rm -f "$TMPFILE"
echo "  Extracted OK"

# ── 5. Patch binaries with /opt/glibc-2.33 ───────────────────────────────────
echo "[5/7] Patching ELF binaries with patchelf ..."

RPATH="${GLIBC_PATH}:/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu"

for BIN in "$INSTALL_DIR/bin/node" "$INSTALL_DIR/bin/npm" "$INSTALL_DIR/bin/npx"; do
    REAL_BIN=$(readlink -f "$BIN" 2>/dev/null || echo "")
    [ -z "$REAL_BIN" ] && continue
    [ ! -x "$REAL_BIN" ] && continue
    # only patch ELF executables, not shell scripts
    if file "$REAL_BIN" | grep -q ELF; then
        echo "  Patching: $REAL_BIN"
        "$PATCHELF" --set-rpath "$RPATH" "$REAL_BIN"
        "$PATCHELF" --set-interpreter "$GLIBC_LINKER" "$REAL_BIN"
        echo "    rpath      -> $RPATH"
        echo "    interpreter-> $GLIBC_LINKER"
    fi
done

# ── 6. Register with update-my-alternatives ──────────────────────────────────
echo "[6/7] Registering with update-my-alternatives ..."

mkdir -p "$HOME/.local/var/lib/alternatives" \
         "$HOME/.local/etc/alternatives" \
         "$HOME/.local/bin"

ALT_CMD="update-alternatives --altdir $HOME/.local/etc/alternatives --admindir $HOME/.local/var/lib/alternatives"

$ALT_CMD --install "$HOME/.local/bin/node"  node  "$INSTALL_DIR/bin/node"  100
$ALT_CMD --install "$HOME/.local/bin/npm"   npm   "$INSTALL_DIR/bin/npm"   100
$ALT_CMD --install "$HOME/.local/bin/npx"   npx   "$INSTALL_DIR/bin/npx"   100

echo "  Registered: node / npm / npx  -> $INSTALL_DIR/bin/"

# ── 7. Create node wrapper for glibc loader execution ────────────────────────
echo "[7/7] Creating node launcher wrapper ..."

NODE_WRAPPER="$HOME/.local/bin/node"
NODE_VERSIONED="$HOME/.local/bin/node-${NODE_VERSION}"

if [ -e "$NODE_VERSIONED" ] || [ -L "$NODE_VERSIONED" ]; then
    rm -f "$NODE_VERSIONED"
fi

if [ -e "$NODE_WRAPPER" ] || [ -L "$NODE_WRAPPER" ]; then
    mv "$NODE_WRAPPER" "$NODE_VERSIONED"
else
    ln -s "$INSTALL_DIR/bin/node" "$NODE_VERSIONED"
fi

cat > "$NODE_WRAPPER" <<EOF
#!/bin/bash
SCRIPT_DIR="\$(cd "\$(dirname "\$0")" && pwd)"

/opt/glibc-2.33/lib/ld-linux-x86-64.so.2 \\
  --library-path /opt/glibc-2.33/lib \\
  "\$SCRIPT_DIR/node-${NODE_VERSION}" "\$@"
EOF

chmod +x "$NODE_WRAPPER"
echo "  Created wrapper : $NODE_WRAPPER"
echo "  Target launcher : $NODE_VERSIONED"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "=== Installation complete ==="
echo "  Node.js $NODE_VERSION installed to $INSTALL_DIR"
echo "  Symlinks:"
echo "    $HOME/.local/bin/node"
echo "    $HOME/.local/bin/npm"
echo "    $HOME/.local/bin/npx"
echo ""
echo "Make sure $HOME/.local/bin is in your PATH:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
echo ""
echo "Verify with:"
echo "  \$HOME/.local/bin/node --version"
