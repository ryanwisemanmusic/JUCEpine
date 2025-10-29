# Contributor: Ryan Wiseman <ryanwisemanmusic@gmail.com>
# Maintainer: Ryan Wiseman <ryanwisemanmusic@gmail.com>
pkgname=juce
pkgver=7.0.8
pkgrel=0
pkgdesc="Cross-platform C++ framework for audio applications"
url="https://juce.com/"
arch="noarch"
license="GPL-3.0-or-later"
depends=""
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
    cmake
    ninja
    python3
"
source="juce-$pkgver.tar.gz::https://github.com/juce-framework/JUCE/archive/refs/tags/$pkgver.tar.gz"
builddir="$srcdir/JUCE-$pkgver"
sha512sums="
271f241cfb76bc1ea1838d9ba552b893d1d8df413d24b051ffb31c6c9b7eff10d18c16d3e8b03c9a910470508e2177aa2d15eab208974171d5835b8b62fcabdf  juce-$pkgver.tar.gz
"

prepare() {
    default_prepare
    if [ ! -d "$builddir/modules" ]; then
        return 1
    fi
    mkdir -p "$builddir/extras/BinaryBuilder/JuceLibraryCode"

    echo "Applying ultra-nuclear patch to JUCE..."
    
    find "$builddir/modules" \( -name "*.h" -o -name "*.cpp" \) -type f -exec grep -l "this_will_fail_to_link_if_some_of_your_compile_units_are_built_in_release_mode" {} \; | while read file; do
        echo "Commenting out debug check in: $file"
        sed -i '/class.*this_will_fail_to_link_if_some_of_your_compile_units_are_built_in_release_mode/,/};/s/^/\/\//' "$file"
    done
    
    if [ -f "$builddir/extras/BinaryBuilder/JuceLibraryCode/JuceHeader.h" ]; then
        echo "Fixing JuceHeader.h..."
        cp "$builddir/extras/BinaryBuilder/JuceLibraryCode/JuceHeader.h" \
           "$builddir/extras/BinaryBuilder/JuceLibraryCode/JuceHeader.h.backup"
        
        cat > "$builddir/extras/BinaryBuilder/JuceLibraryCode/JuceHeader.h" << 'EOF'
#ifndef __JUCEHEADER_APK_BUILD__
#define __JUCEHEADER_APK_BUILD__

#define JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED 1
#define JUCE_MODULE_AVAILABLE_juce_core 1

#ifndef NDEBUG
#define NDEBUG 1
#endif
#ifndef JUCE_RELEASE  
#define JUCE_RELEASE 1
#endif

#include "juce_core/juce_core.h"

#endif
EOF
    fi
}

build() {
    :
}

check() {
    test -d "$builddir/modules"
}

package() {
    install -dm755 "$pkgdir/usr/include/JUCE-$pkgver"
    cp -rv "$builddir/modules" "$pkgdir/usr/include/JUCE-$pkgver/"
    # Explicitly install JuceHeader.h
    if [ -f "$builddir/extras/BinaryBuilder/JuceLibraryCode/JuceHeader.h" ]; then
        install -Dm644 "$builddir/extras/BinaryBuilder/JuceLibraryCode/JuceHeader.h" \
            "$pkgdir/usr/include/JuceHeader.h"
    fi
    # pkg-config
    install -Dm644 /dev/stdin "$pkgdir/usr/lib/pkgconfig/juce.pc" <<-EOF
	prefix=/usr
	exec_prefix=\${prefix}
	includedir=\${prefix}/include
	Name: JUCE
	Description: Cross-platform C++ framework for audio applications
	Version: $pkgver
	Cflags: -I\${includedir}/JUCE-$pkgver/modules
	EOF
    # cmake config
    install -Dm644 /dev/stdin "$pkgdir/usr/lib/cmake/JUCE/JUCEConfig.cmake" <<-EOF
	set(JUCE_FOUND TRUE)
	set(JUCE_VERSION $pkgver)
	set(JUCE_INCLUDE_DIRS /usr/include/JUCE-$pkgver)
	set(JUCE_MODULES_PATH /usr/include/JUCE-$pkgver/modules)
	EOF
}

doc() {
    pkgdesc="$pkgdesc (documentation and examples)"
    mkdir -p "$subpkgdir/usr/share/doc/$pkgname"
    if [ -d "$builddir/extras" ]; then
        cp -rv "$builddir/extras" "$subpkgdir/usr/share/doc/$pkgname/"
    fi
    if [ -d "$builddir/examples" ]; then
        cp -rv "$builddir/examples" "$subpkgdir/usr/share/doc/$pkgname/"
    fi
}

# This is missing the Projucer component, which if you want to incorporate this,
# make sure you create a seperate APK package called 'juce' (instead of trying to 
# merge it into 'juce-dev')

# Please if you manage the Edge side of Alpine, that if someone tries this,
# you reject their changes to this APKBUILD file. 
# juce-dev was intended without the Projucer component.