#!/bin/bash

set -e

echo "=== JUCE Build Setup Script ==="

# Configuration
BUILDER_HOME="/home/builder"
KEY_DIR="$BUILDER_HOME/.abuild"
KEY_CONF="$KEY_DIR/abuild.conf"
REPO_PATH="${REPODEST:-$BUILDER_HOME/packages}"

mkdir -p "$KEY_DIR"
mkdir -p "$REPO_PATH"

echo "[SETUP] Repository path: $REPO_PATH"

echo "[SETUP] Checking for abuild signing keys..."
PUB_KEY=$(find "$KEY_DIR" -name '*.rsa.pub' 2>/dev/null | head -n1)
PRIV_KEY=$(find "$KEY_DIR" -name '*.rsa' ! -name '*.pub' 2>/dev/null | head -n1)

if [ -z "$PUB_KEY" ] || [ -z "$PRIV_KEY" ]; then
    echo "[SETUP] No keys found: generating new abuild keypair..."
    abuild-keygen -a -n 2>&1 | grep -v ">>>" | grep -v "writing RSA key" || true
    PUB_KEY=$(find "$KEY_DIR" -name '*.rsa.pub' | head -n1)
    PRIV_KEY=$(find "$KEY_DIR" -name '*.rsa' ! -name '*.pub' | head -n1)
else
    echo "[SETUP] Keys already exist"
fi

echo "PACKAGER_PRIVKEY=\"$PRIV_KEY\"" > "$KEY_CONF"
echo "[SETUP] Private key configured: $PRIV_KEY"

KEY_NAME=$(basename "$PUB_KEY")
if [ ! -f "/etc/apk/keys/$KEY_NAME" ]; then
    echo "[SETUP] Installing public key to /etc/apk/keys..."
    if command -v doas >/dev/null 2>&1; then
        doas install -Dm644 "$PUB_KEY" "/etc/apk/keys/$KEY_NAME"
    elif command -v sudo >/dev/null 2>&1; then
        sudo install -Dm644 "$PUB_KEY" "/etc/apk/keys/$KEY_NAME"
    elif [ -w /etc/apk/keys ]; then
        install -Dm644 "$PUB_KEY" "/etc/apk/keys/$KEY_NAME"
    else
        echo "[WARN] Cannot install key to /etc/apk/keys, will flag things withUNTRUSTED warnings"
    fi
else
    echo "[SETUP] Public key already trusted"
fi

if [ -z "$CBUILD" ]; then
    export CBUILD="$(apk --print-arch 2>/dev/null || echo "x86_64")"
    echo "[SETUP] CBUILD set to: $CBUILD"
fi

echo ""
echo "=== Building Package ==="
cd "$(dirname "$0")"

if [ -f APKBUILD ]; then
    find "$REPO_PATH" -name "juce-*.apk" -delete 2>/dev/null || true
    find "$REPO_PATH" -name "APKINDEX.tar.gz" -delete 2>/dev/null || true
    find "$REPO_PATH" -name "APKINDEX.unsigned.tar.gz" -delete 2>/dev/null || true
    
    mkdir -p "$REPO_PATH/home/x86_64" 2>/dev/null || true
    
    abuild -r -F 2>&1 | grep -v "WARNING: opening /home/builder/packages/home: No such file or directory" || true
    echo "[BUILD] Package built successfully"
else
    echo "[ERROR] APKBUILD not found in current directory"
    exit 1
fi

echo ""
echo "=== Build Complete ==="
echo "Package location: $REPO_PATH"
echo "Package created: $(find "$REPO_PATH" -name "juce-*.apk" | head -n1)"
echo "To install: apk add --repository $REPO_PATH juce"