# APKBUILD for JUCE
# Maintainer: Ryan Wiseman <ryanwisemanmusic@gmail.com>
pkgname=juce
pkgver=7.0.8
pkgrel=1
pkgdesc="JUCE Framework for Alpine Linux (headers only)"
url="https://juce.com"
arch="x86_64"
license="GPL3"
depends="freetype libx11 libxrandr libxinerama libxcursor mesa alsa-lib curl gtk+3.0"
depends_dev=""
makedepends="
    build-base
    bash
    git
    curl
    ca-certificates
    freetype-dev
    libx11-dev
    libxrandr-dev
    libxinerama-dev
    libxcursor-dev
    mesa-dev
    gtk+3.0-dev
    alsa-lib-dev
    curl-dev
    gcompat
    abuild
    doas
    cmake
    ninja
    python3
    unzip
    $depends_dev
"
subpackages=""
source="
    juce-$pkgver.tar.gz::https://github.com/juce-framework/JUCE/archive/refs/tags/$pkgver.tar.gz
"
sha512sums="
271f241cfb76bc1ea1838d9ba552b893d1d8df413d24b051ffb31c6c9b7eff10d18c16d3e8b03c9a910470508e2177aa2d15eab208974171d5835b8b62fcabdf  juce-$pkgver.tar.gz
"
builddir="$srcdir/JUCE-$pkgver"
# This is key related code
KEY_DIR="$HOME/.abuild"
KEY_CONF="$KEY_DIR/abuild.conf"
mkdir -p "$KEY_DIR"
# If we do not find any valid key, then we generate it. 
if ! find "$KEY_DIR" -type f -name "*.rsa" | grep -q .; then
    echo "No abuild key detected — generating..."
    abuild-keygen -a -n
    PRIV_KEY=$(find "$KEY_DIR" -type f -name "*.rsa" ! -name "*.pub" | head -n1)
    echo "PACKAGER_PRIVKEY=\"$PRIV_KEY\"" > "$KEY_CONF"
    echo "Generated and configured private key: $PRIV_KEY"
else
    echo "Abuild key already exists"
fi

prepare() {
    default_prepare
    echo "[DEBUG] Running as $(whoami)"
    # Key needs to be sourced from the builder's home directory
    BUILDER_HOME="/home/builder"
    KEY_DIR="$BUILDER_HOME/.abuild"
    KEY_CONF="$KEY_DIR/abuild.conf"
    mkdir -p "$KEY_DIR"
    PUB_KEY=$(find "$KEY_DIR" -name '*.rsa.pub' | head -n1)
    PRIV_KEY=$(find "$KEY_DIR" -name '*.rsa' ! -name '*.pub' | head -n1)
    # And then if we still cannot find the keys, then we generate them
    if [ -z "$PUB_KEY" ] || [ -z "$PRIV_KEY" ]; then
        echo "[INIT] No abuild keys detected — generating..."
        abuild-keygen -a -n
        PUB_KEY=$(find "$KEY_DIR" -name '*.rsa.pub' | head -n1)
        PRIV_KEY=$(find "$KEY_DIR" -name '*.rsa' ! -name '*.pub' | head -n1)
        echo "PACKAGER_PRIVKEY=\"$PRIV_KEY\"" > "$KEY_CONF"
        echo "[INIT] Generated and configured private key: $PRIV_KEY"
        if [ -w /etc/apk/keys ] || [ "$(id -u)" -eq 0 ]; then
            install -Dm644 "$PUB_KEY" /etc/apk/keys/$(basename "$PUB_KEY")
            echo "Public key installed to /etc/apk/keys"
        else
            echo "CRITICAL: Cannot install public key to /etc/apk/keys"
        fi
    else
        echo "Abuild keys already present"
    fi
    if [ -d "$builddir/modules" ]; then
        echo "modules located"
    else
        echo "FATAL: modules directory missing in $builddir"
        ls -la "$builddir" || true
        return 1
    fi
    # JuceHeader.h verification
    HEADER="$builddir/extras/BinaryBuilder/JuceLibraryCode/JuceHeader.h"
    if [ ! -f "$HEADER" ]; then
        echo "JuceHeader.h missing, creating alt (need to replace)"
        mkdir -p "$(dirname "$HEADER")"
    else
        echo "Success - JuceHeader.h "
    fi
}

build() {
    echo "=== BUILD PHASE ==="
    cd "$builddir" || return 1
    echo "✓ Build phase complete (headers-only package)"
}

check() {
    [ -d "$builddir/modules" ] && echo "JUCE modules found" || { echo "JUCE modules missing"; return 1; }
    [ -f "$builddir/extras/BinaryBuilder/JuceLibraryCode/JuceHeader.h" ] && echo "JuceHeader.h found" || echo "CRITICAL: JuceHeader.h missing"
}

package() {
    mkdir -p "$pkgdir/usr/include/JUCE-$pkgver"
    mkdir -p "$pkgdir/usr/share/juce"
    mkdir -p "$pkgdir/usr/lib/pkgconfig"
    mkdir -p "$pkgdir/usr/lib/cmake/JUCE"
    if [ -d "$builddir/modules" ]; then
        echo "Copying modules to $pkgdir/usr/include/JUCE-$pkgver/"
        cp -rv "$builddir/modules" "$pkgdir/usr/include/JUCE-$pkgver/"
    else
        echo "FATAL: modules directory missing at $builddir/modules"
        return 1
    fi
    HEADER="$builddir/extras/BinaryBuilder/JuceLibraryCode/JuceHeader.h"
    if [ -f "$HEADER" ]; then
        echo "Copying JuceHeader.h to $pkgdir/usr/include/"
        cp -v "$HEADER" "$pkgdir/usr/include/"
    else
        echo "CRITICAL: JuceHeader.h missing at $HEADER"
    fi
    if [ -d "$builddir/extras" ]; then
        echo "Copying extras to $pkgdir/usr/share/juce/"
        cp -rv "$builddir/extras" "$pkgdir/usr/share/juce/"
    fi
    if [ -d "$builddir/examples" ]; then
        echo "Copying examples to $pkgdir/usr/share/juce/"
        cp -rv "$builddir/examples" "$pkgdir/usr/share/juce/"
    fi
    cat > "$pkgdir/usr/lib/pkgconfig/juce.pc" <<EOF
prefix=/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: JUCE
Description: JUCE Cross-Platform C++ Framework (headers only)
Version: $pkgver
Cflags: -I\${includedir}/JUCE
Libs:
EOF

    cat > "$pkgdir/usr/lib/cmake/JUCE/JUCEConfig.cmake" <<EOF
set(JUCE_FOUND TRUE)
set(JUCE_VERSION $pkgver)
set(JUCE_INCLUDE_DIRS /usr/include/JUCE-$pkgver)
set(JUCE_MODULES_PATH /usr/include/JUCE-$pkgver/modules)
EOF
}

# A note to anyone who wants to work on this, JUCE is one of the most Alpine-unfriendly frameworks.
# It is not as simple as creating something close to the code of others, but accounting for the fact it's a framework
# Yes you may hate me for choosing to pick such a pain in the ass framework to implement, it did not exist
# and I thought it would be a fun project for a month