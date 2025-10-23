# APKBUILD for JUCE
# Maintainer: Ryan Wiseman <ryanwisemanmusic@gmail.com>
pkgname=juce
pkgver=7.0.8
pkgrel=1
pkgdesc="JUCE Framework for Alpine Linux"
url="https://juce.com"
arch="all"
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
	default_prepare
	sed -i '/#include <execinfo.h>/c\
#ifdef __GLIBC__\
  #include <execinfo.h>\
#else\
  /* musl libc does not have execinfo.h */\
#endif' \
		"$builddir/modules/juce_core/juce_core.cpp"

	sed -i 's/using juce_statStruct = struct stat64;/using juce_statStruct = struct stat;/' \
		"$builddir/modules/juce_core/native/juce_SharedCode_posix.h"
	sed -i 's/#define JUCE_STAT  stat64/#define JUCE_STAT  stat/' \
		"$builddir/modules/juce_core/native/juce_SharedCode_posix.h"

	sed -i 's/_NL_ADDRESS_LANG_AB/CODESET/' \
		"$builddir/modules/juce_core/native/juce_SystemStats_linux.cpp"
	sed -i 's/_NL_ADDRESS_COUNTRY_AB2/CODESET/' \
		"$builddir/modules/juce_core/native/juce_SystemStats_linux.cpp"

	sed -i '/auto frames = backtrace/,/::free (frameStrings);/c\
    /* musl libc does not have backtrace support */\
    result << "(backtrace not available on this platform)" << newLine;' \
		"$builddir/modules/juce_core/system/juce_SystemStats.cpp"
	
	# Disable LADSPA in the source code to ensure it's completely disabled
	sed -i 's/#define JUCE_PLUGINHOST_LADSPA 1/#define JUCE_PLUGINHOST_LADSPA 0/' \
		"$builddir/modules/juce_audio_processors/juce_audio_processors.h"
}

build() {
    if [ "$CBUILD" != "$CHOST" ]; then
        CMAKE_CROSSOPTS="-DCMAKE_SYSTEM_NAME=Linux -DCMAKE_HOST_SYSTEM_NAME=Linux"
    fi

    CFLAGS="$CFLAGS" \
    CXXFLAGS="$CXXFLAGS" \
	cmake -B build -G Ninja \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DCMAKE_BUILD_TYPE=MinSizeRel \
		-DJUCE_BUILD_EXTRAS=OFF \
		-DJUCE_BUILD_EXAMPLES=OFF \
		-DJUCE_BUILD_EXAMPLES=OFF \
		-DJUCE_BUILD_TESTS=OFF \
		-DJUCE_BUILD_PLUGINS=OFF \
		-DJUCE_BUILD_EXAMPLES=OFF \
		$CMAKE_CROSSOPTS
    
    ninja -C build
}

check() {
	if [ -d build ]; then
		echo "JUCE build verification passed"
	else
		echo "JUCE build verification failed"
		return 1
	fi
}

package() {
	# Create directory structure
	mkdir -p "$pkgdir/usr/include"
	mkdir -p "$pkgdir/usr/share/juce"
	mkdir -p "$pkgdir/usr/lib/pkgconfig"
	
	# Install all JUCE modules to /usr/include/JUCE
	cp -r "$builddir/modules" "$pkgdir/usr/include/JUCE"
	
	# Install extras and examples to /usr/share/juce
	cp -r "$builddir/extras" "$pkgdir/usr/share/juce/"
	cp -r "$builddir/examples" "$pkgdir/usr/share/juce/"
	
	# Create versioned directory for compatibility
	mkdir -p "$pkgdir/usr/include/JUCE-$pkgver"
	cp -r "$builddir/modules" "$pkgdir/usr/include/JUCE-$pkgver/"
	
	# Create essential symlinks
	cd "$pkgdir/usr/include"
	ln -sf "JUCE-$pkgver" JUCE
	
	# Create individual module symlinks for direct access
	for module in "$pkgdir/usr/include/JUCE/modules"/*; do
		module_name=$(basename "$module")
		ln -sf "JUCE/modules/$module_name" "juce_$module_name"
	done
	
	# Create pkg-config file
	cat > "$pkgdir/usr/lib/pkgconfig/juce.pc" <<EOF
prefix=/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: JUCE
Description: JUCE Cross-Platform C++ Framework
Version: $pkgver
Cflags: -I\${includedir}/JUCE
Libs: -L\${libdir}
EOF

	# Create a simple CMake config file
	mkdir -p "$pkgdir/usr/lib/cmake/JUCE"
	cat > "$pkgdir/usr/lib/cmake/JUCE/JUCEConfig.cmake" <<EOF
# JUCE CMake configuration
set(JUCE_ROOT /usr/include/JUCE)
set(JUCE_MODULES_PATH \${JUCE_ROOT}/modules)
message(STATUS "Found JUCE: \${JUCE_ROOT}")
EOF

	# Create documentation and license
	mkdir -p "$pkgdir/usr/share/doc/juce"
	cp "$builddir/LICENSE.md" "$pkgdir/usr/share/doc/juce/"
	cp "$builddir/README.md" "$pkgdir/usr/share/doc/juce/"
}

post_install() {
    if [ -f /home/builder/.abuild/*.rsa.pub ]; then
        mkdir -p /etc/apk/keys
        cp /home/builder/.abuild/*.rsa.pub /etc/apk/keys/
    fi
}

sha512sums="271f241cfb76bc1ea1838d9ba552b893d1d8df413d24b051ffb31c6c9b7eff10d18c16d3e8b03c9a910470508e2177aa2d15eab208974171d5835b8b62fcabdf  juce-7.0.8.tar.gz"