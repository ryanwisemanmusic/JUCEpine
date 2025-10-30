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
makedepends="cmake samurai"
options="!check"
subpackages="$pkgname-doc"
source="juce-$pkgver.tar.gz::https://github.com/juce-framework/JUCE/archive/refs/tags/$pkgver.tar.gz
	"
builddir="$srcdir/JUCE-$pkgver"

sha512sums="
271f241cfb76bc1ea1838d9ba552b893d1d8df413d24b051ffb31c6c9b7eff10d18c16d3e8b03c9a910470508e2177aa2d15eab208974171d5835b8b62fcabdf  juce-$pkgver.tar.gz
"

prepare() {
	default_prepare
	
	# Verify JUCE structure
	if [ ! -d "$builddir/modules" ]; then
		error "modules directory missing in $builddir"
		return 1
	fi
	
	# Generate our config header that sets proper build mode
	mkdir -p "$builddir/modules/juce_core/juce_core"
	install -Dm644 /dev/stdin "$builddir/modules/juce_core/juce_core/juce-config.h" <<-EOF
	/*
	  ==============================================================================
	   
	   Alpine Linux JUCE Configuration Header
	   
	   This file provides default configuration for JUCE when used as a system
	   package on Alpine Linux. It ensures consistent build settings across all
	   applications using JUCE from the Alpine repository.
	   
	  ==============================================================================
	*/
	#pragma once

	// Release mode definitions
	#ifndef NDEBUG
	#define NDEBUG
	#endif

	#ifndef _NDEBUG  
	#define _NDEBUG
	#endif

	// JUCE specific settings
	#define JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED 1
	#define JUCE_STANDALONE_APPLICATION 1
	#define JUCE_USE_CURL 0
	#define JUCE_WEB_BROWSER 0
	#define JUCE_MODAL_LOOPS_PERMITTED 1

	// Add any other JUCE specific configurations here
	#define JUCE_FORCE_DEBUG 0
	#define JUCE_LOG_ASSERTIONS 0
	#define JUCE_CHECK_MEMORY_LEAKS 0
	EOF
}

build() {
	# Capture build output
    BUILDLOG="/tmp/juce-build.log"
    exec 1> >(tee -a "$BUILDLOG")
    exec 2>&1
}

package() {
	# Install JUCE modules
	msg "Installing JUCE modules..."
	install -dm755 "$pkgdir/usr/include/JUCE-$pkgver"
	cp -r "$builddir/modules" "$pkgdir/usr/include/JUCE-$pkgver/"
	
	# Install pkg-config file
	install -Dm644 /dev/stdin "$pkgdir/usr/lib/pkgconfig/juce.pc" <<-EOF
	prefix=/usr
	exec_prefix=\${prefix}
	includedir=\${prefix}/include
	
	Name: JUCE
	Description: Cross-platform C++ framework for audio applications
	Version: $pkgver
	Cflags: -I\${includedir}/JUCE-$pkgver/modules -DNDEBUG -DJUCE_DISABLE_ASSERTIONS=1 -DJUCE_GLOBAL_MODULE_SETTINGS_INCLUDED=1 -include juce_core/juce_core/juce-config.h
	Libs: -lexecinfo
	EOF
	
	# Install CMake config
	install -Dm644 /dev/stdin "$pkgdir/usr/lib/cmake/JUCE/JUCEConfig.cmake" <<-EOF
	set(JUCE_FOUND TRUE)
	set(JUCE_VERSION $pkgver)
	set(JUCE_INCLUDE_DIRS /usr/include/JUCE-$pkgver/modules)
	set(JUCE_MODULES_PATH /usr/include/JUCE-$pkgver/modules)
	add_compile_definitions(JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED=1)
	EOF
}

subpackages="$pkgname-doc $pkgname-examples $pkgname-extras"

doc() {
    pkgdesc="$pkgdesc (documentation)"
    mkdir -p "$subpkgdir/usr/share/doc/$pkgname"
}

examples() {
    pkgdesc="$pkgdesc (example code)"
    if [ -d "$builddir/examples" ]; then
		mkdir -p "$subpkgdir/usr/share/$pkgname"
		cp -r "$builddir/examples" "$subpkgdir/usr/share/$pkgname/examples"
    fi
}

extras() {
    pkgdesc="$pkgdesc (additional utilities)"
    if [ -d "$builddir/extras" ]; then
		mkdir -p "$subpkgdir/usr/share/$pkgname"
		cp -r "$builddir/extras" "$subpkgdir/usr/share/$pkgname/extras"
    fi
}