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
	cmake
	ninja
	python3
	freetype-dev
	libx11-dev
	libxrandr-dev
	libxinerama-dev
	libxcursor-dev
	mesa-dev
	alsa-lib-dev
	curl-dev
	gtk+3.0-dev
	$depends_dev
	"

subpackages="$pkgname-dev"
source="juce-$pkgver.tar.gz::https://github.com/juce-framework/JUCE/archive/refs/tags/$pkgver.tar.gz"

builddir="$srcdir/JUCE-$pkgver"

prepare() {
    echo "=== PREPARE PHASE ==="

    mkdir -p "$HOME/.abuild"

    if [ ! -f "$HOME/.abuild/juce-temp.rsa" ]; then
        echo "Generating temporary abuild key (local only)..."
        abuild-keygen -a -n -p "$HOME/.abuild/juce-temp.rsa" || true
    fi

    default_prepare
}

build() {
	echo "=== BUILD PHASE ==="
	cd "$builddir" || return 1
}

check() {
	echo "=== CHECK PHASE ==="
	if [ -d "$builddir/modules" ]; then
		echo "✓ JUCE modules found"
	else
		echo "✗ JUCE modules missing"
		return 1
	fi
}

package() {
	echo "=== PACKAGE PHASE ==="
	mkdir -p "$pkgdir/usr/include"

	cp -rv "$builddir/modules" "$pkgdir/usr/include/JUCE"

	if [ -f "$builddir/extras/BinaryBuilder/JuceLibraryCode/JuceHeader.h" ]; then
		cp -v "$builddir/extras/BinaryBuilder/JuceLibraryCode/JuceHeader.h" "$pkgdir/usr/include/"
	fi

	mkdir -p "$pkgdir/usr/include/JUCE-$pkgver"
	cp -rv "$builddir/modules" "$pkgdir/usr/include/JUCE-$pkgver/"
	ln -sfv "JUCE-$pkgver" "$pkgdir/usr/include/JUCE"

	mkdir -p "$pkgdir/usr/share/juce"
	cp -rv "$builddir/extras" "$pkgdir/usr/share/juce/"
	cp -rv "$builddir/examples" "$pkgdir/usr/share/juce/"

	mkdir -p "$pkgdir/usr/lib/pkgconfig"
	cat > "$pkgdir/usr/lib/pkgconfig/juce.pc" <<EOF
prefix=/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: JUCE
Description: JUCE Cross-Platform C++ Framework (headers only)
Version: $pkgver
Cflags: -I\${includedir}
Libs:
EOF

	mkdir -p "$pkgdir/usr/lib/cmake/JUCE"
	cat > "$pkgdir/usr/lib/cmake/JUCE/JUCEConfig.cmake" <<EOF
set(JUCE_FOUND TRUE)
set(JUCE_VERSION $pkgver)
set(JUCE_INCLUDE_DIRS /usr/include)
set(JUCE_MODULES_PATH /usr/include/JUCE/modules)
EOF
}

sha512sums="271f241cfb76bc1ea1838d9ba552b893d1d8df413d24b051ffb31c6c9b7eff10d18c16d3e8b03c9a910470508e2177aa2d15eab208974171d5835b8b62fcabdf  juce-7.0.8.tar.gz"
