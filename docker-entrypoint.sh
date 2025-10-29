#!/bin/bash

set -e

echo "=== Docker Container Setup ==="
BUILDER_HOME="${BUILDER_HOME:-/home/builder}"
KEY_DIR="$BUILDER_HOME/.abuild"
REPO_PATH="${REPODEST:-$BUILDER_HOME/packages}"

mkdir -p "$KEY_DIR"
mkdir -p "$REPO_PATH/home/x86_64"

CURRENT_USER=$(whoami)

if [ ! -f "$KEY_DIR"/*.rsa.pub ]; then
    echo "[DOCKER] Generating abuild keys..."
    if [ "$CURRENT_USER" = "builder" ]; then
        abuild-keygen -a -n 2>&1 | grep -v ">>>" | grep -v "writing RSA key" || true
    else
        su builder -c "abuild-keygen -a -n" 2>&1 | grep -v ">>>" | grep -v "writing RSA key" || true
    fi
    echo "[DOCKER] Keys generated"
fi

echo "[DOCKER] Installing public key to /etc/apk/keys..."
if [ "$CURRENT_USER" = "builder" ]; then
    doas mkdir -p /etc/apk/keys 2>/dev/null
    doas cp "$KEY_DIR"/*.rsa.pub /etc/apk/keys/ 2>/dev/null || true
    doas chmod 644 /etc/apk/keys/*.pub 2>/dev/null || true
else
    mkdir -p /etc/apk/keys 2>/dev/null
    cp "$KEY_DIR"/*.rsa.pub /etc/apk/keys/ 2>/dev/null || true
    chmod 644 /etc/apk/keys/*.pub 2>/dev/null || true
fi

if [ ! -f "$REPO_PATH/home/x86_64/APKINDEX.tar.gz" ]; then
    (cd "$REPO_PATH/home/x86_64" && tar -czf APKINDEX.tar.gz --files-from=/dev/null 2>/dev/null) || true
fi

echo "[DOCKER] Setup complete"
echo ""
exec "$@"