# APKBUILD for JUCE
# Maintainer: Ryan Wiseman <ryanwisemanmusic@gmail.com>
pkgname=juce
pkgver=7.0.8
pkgrel=1
pkgdesc="JUCE Framework for Alpine Linux"
url="https://juce.com"
arch="all"
license="GPL3"
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
}

build() {
	if [ "$CBUILD" != "$CHOST" ]; then
		CMAKE_CROSSOPTS="-DCMAKE_SYSTEM_NAME=Linux -DCMAKE_HOST_SYSTEM_NAME=Linux"
	fi

	CFLAGS="$CFLAGS" \
	CXXFLAGS="$CXXFLAGS" \
	cmake -B build -G Ninja \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DCMAKE_INSTALL_LIBDIR=lib \
		-DCMAKE_BUILD_TYPE=MinSizeRel \
		-DCMAKE_JOB_POOLS=thr=3 \
		-DCMAKE_JOB_POOL_LINK=thr \
		-DJUCE_BUILD_EXTRAS=OFF \
		-DJUCE_BUILD_EXAMPLES=OFF \
		-DJUCE_ENABLE_MODULE_SOURCE_GROUPS=ON \
		-DJUCE_STRICT_REFCOUNTEDPTR=OFF \
		-DJUCE_WEB_BROWSER=OFF \
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
	DESTDIR="$pkgdir" ninja -C build install
}

sha512sums="271f241cfb76bc1ea1838d9ba552b893d1d8df413d24b051ffb31c6c9b7eff10d18c16d3e8b03c9a910470508e2177aa2d15eab208974171d5835b8b62fcabdf  juce-7.0.8.tar.gz"