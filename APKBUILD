# APKBUILD for JUCE
# Maintainer: Ryan Wiseman <ryanwisemanmusic@gmail.com>

pkgname=juce
pkgver=7.0.8
pkgrel=1
pkgdesc="JUCE Framework for Alpine Linux (headers only)"
url="https://juce.com"
arch="x86_64"
license="GPL3"

# Runtime dependencies
depends="freetype libx11 libxrandr libxinerama libxcursor mesa alsa-lib curl gtk+3.0"
depends_dev=""

# Build-time dependencies
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

# Sources
source="
    juce-$pkgver.tar.gz::https://github.com/juce-framework/JUCE/archive/refs/tags/$pkgver.tar.gz
"

# Checksums
sha512sums="
271f241cfb76bc1ea1838d9ba552b893d1d8df413d24b051ffb31c6c9b7eff10d18c16d3e8b03c9a910470508e2177aa2d15eab208974171d5835b8b62fcabdf  juce-$pkgver.tar.gz
"

builddir="$srcdir/JUCE-$pkgver"

prepare() {
    default_prepare

    echo "=== PREPARE PHASE ==="
    echo "[DEBUG] srcdir = $srcdir"
    echo "[DEBUG] builddir = $builddir"

    # Verify the extracted source structure
    if [ -d "$builddir/modules" ]; then
        echo "✓ modules directory found in extracted source"
    else
        echo "✗ ERROR: modules directory not found in extracted source"
        echo "Contents of builddir:"
        ls -la "$builddir" || true
        return 1
    fi

    # Ensure JuceHeader.h exists (create placeholder if missing)
    HEADER="$builddir/extras/BinaryBuilder/JuceLibraryCode/JuceHeader.h"
    if [ ! -f "$HEADER" ]; then
        echo "⚠ JuceHeader.h missing, creating placeholder..."
        mkdir -p "$(dirname "$HEADER")"
        touch "$HEADER"
    fi
}

build() {
    echo "=== BUILD PHASE ==="
    # For a headers-only package, there's nothing to build
    # Just verify the source is present
    cd "$builddir" || return 1
    echo "✓ Build phase complete (headers-only package)"
}

check() {
    echo "=== CHECK PHASE ==="

    [ -d "$builddir/modules" ] && echo "✓ JUCE modules found" || { echo "✗ JUCE modules missing"; return 1; }
    [ -f "$builddir/extras/BinaryBuilder/JuceLibraryCode/JuceHeader.h" ] && echo "✓ JuceHeader.h found" || echo "⚠ WARNING: JuceHeader.h missing"
}

package() {
    echo "=== PACKAGE PHASE ==="

    # Create directories
    mkdir -p "$pkgdir/usr/include/JUCE-$pkgver"
    mkdir -p "$pkgdir/usr/share/juce"
    mkdir -p "$pkgdir/usr/lib/pkgconfig"
    mkdir -p "$pkgdir/usr/lib/cmake/JUCE"

    # Copy modules safely
    if [ -d "$builddir/modules" ]; then
        echo "Copying modules to $pkgdir/usr/include/JUCE-$pkgver/"
        cp -rv "$builddir/modules" "$pkgdir/usr/include/JUCE-$pkgver/"
    else
        echo "✗ ERROR: modules directory missing at $builddir/modules"
        return 1
    fi

    # JuceHeader.h
    HEADER="$builddir/extras/BinaryBuilder/JuceLibraryCode/JuceHeader.h"
    if [ -f "$HEADER" ]; then
        echo "Copying JuceHeader.h to $pkgdir/usr/include/"
        cp -v "$HEADER" "$pkgdir/usr/include/"
    else
        echo "⚠ WARNING: JuceHeader.h missing at $HEADER"
    fi

    # Extras and examples
    if [ -d "$builddir/extras" ]; then
        echo "Copying extras to $pkgdir/usr/share/juce/"
        cp -rv "$builddir/extras" "$pkgdir/usr/share/juce/"
    fi
    if [ -d "$builddir/examples" ]; then
        echo "Copying examples to $pkgdir/usr/share/juce/"
        cp -rv "$builddir/examples" "$pkgdir/usr/share/juce/"
    fi

    # pkg-config
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

    # CMake
    cat > "$pkgdir/usr/lib/cmake/JUCE/JUCEConfig.cmake" <<EOF
set(JUCE_FOUND TRUE)
set(JUCE_VERSION $pkgver)
set(JUCE_INCLUDE_DIRS /usr/include/JUCE-$pkgver)
set(JUCE_MODULES_PATH /usr/include/JUCE-$pkgver/modules)
EOF

    echo "=== PACKAGE PHASE COMPLETE ==="
}
