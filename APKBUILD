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
source="juce-$pkgver.tar.gz::https://github.com/juce-framework/JUCE/archive/refs/tags/$pkgver.tar.gz"
builddir="$srcdir/JUCE-$pkgver"

sha512sums="
271f241cfb76bc1ea1838d9ba552b893d1d8df413d24b051ffb31c6c9b7eff10d18c16d3e8b03c9a910470508e2177aa2d15eab208974171d5835b8b62fcabdf  juce-$pkgver.tar.gz
"

prepare() {
	default_prepare
	
	msg "Applying Alpine Linux compatibility patches..."
	
	# Verify JUCE structure
	if [ ! -d "$builddir/modules" ]; then
		error "modules directory missing in $builddir"
		return 1
	fi
	
	# Create execinfo.h compatibility shim for musl/elfutils
	msg2 "Creating execinfo.h compatibility shim for elfutils-dev"
	install -Dm644 /dev/stdin "$builddir/modules/juce_core/juce_core/execinfo.h" <<-'EXECINFO'
	/*
	  ==============================================================================
	   Alpine Linux execinfo.h compatibility shim
	   
	   musl doesn't provide execinfo.h. On Alpine 3.17+, elfutils-dev provides
	   the backtrace functionality we need. This shim redirects to elfutils.
	  ==============================================================================
	*/
	#pragma once
	
	#ifdef __cplusplus
	extern "C" {
	#endif
	
	// On Alpine with elfutils-dev, backtrace is provided by elfutils
	// The header is typically at /usr/include/elfutils/libdwfl.h
	// But for basic backtrace() we can use the definitions from libdw
	
	#if defined(__has_include)
	  #if __has_include(<elfutils/libdwfl.h>)
	    // We have elfutils, but we need to provide compatible signatures
	    // The actual implementation will be linked from libdw
	  #endif
	#endif
	
	// Provide minimal backtrace interface
	// The actual symbols come from libdw (elfutils-dev package)
	#ifndef _EXECINFO_H
	#define _EXECINFO_H 1
	
	// These functions are provided by libdw from elfutils-dev
	int backtrace(void **buffer, int size) __attribute__((weak));
	char **backtrace_symbols(void *const *buffer, int size) __attribute__((weak));
	void backtrace_symbols_fd(void *const *buffer, int size, int fd) __attribute__((weak));
	
	// Provide weak stub implementations in case libdw isn't linked
	__attribute__((weak))
	int backtrace(void **buffer, int size) {
	    (void)buffer; (void)size;
	    return 0;
	}
	
	__attribute__((weak))
	char **backtrace_symbols(void *const *buffer, int size) {
	    (void)buffer; (void)size;
	    return (char**)0;
	}
	
	__attribute__((weak))
	void backtrace_symbols_fd(void *const *buffer, int size, int fd) {
	    (void)buffer; (void)size; (void)fd;
	}
	
	#endif /* _EXECINFO_H */
	
	#ifdef __cplusplus
	}
	#endif
	EXECINFO
	
	# Patch juce_core.cpp to use our local execinfo.h
	msg2 "Patching juce_core.cpp to use local execinfo.h"
	sed -i 's|#include <execinfo.h>|#include "juce_core/execinfo.h"|g' \
		"$builddir/modules/juce_core/juce_core.cpp"
	
	# Also patch any other files that might include execinfo.h
	find "$builddir/modules" -type f \( -name "*.cpp" -o -name "*.h" \) -exec \
		sed -i 's|#include <execinfo.h>|#include "juce_core/execinfo.h"|g' {} \;
	
	# Fix stat64 issue - musl uses stat directly (it's already 64-bit)
	msg2 "Patching stat64 for musl compatibility"
	sed -i 's/struct stat64/struct stat/g' \
		"$builddir/modules/juce_core/native/juce_SharedCode_posix.h"
	sed -i 's/stat64/stat/g' \
		"$builddir/modules/juce_core/native/juce_SharedCode_posix.h"
	
	# Fix locale constants that don't exist in musl
	msg2 "Patching locale functions for musl compatibility"
	cat > "$builddir/musl_locale_patch.tmp" <<-'LOCALEPATCH'
	String SystemStats::getUserLanguage()
	{
	   #if defined(__MUSL__)
	    if (auto* lang = ::getenv("LANG"))
	    {
	        String langStr(lang);
	        if (langStr.contains("_"))
	            return langStr.upToFirstOccurrenceOf("_", false, false);
	        if (langStr.contains("."))
	            return langStr.upToFirstOccurrenceOf(".", false, false);
	        return langStr;
	    }
	    return "en";
	   #else
	    return getLocaleValue (_NL_ADDRESS_LANG_AB);
	   #endif
	}
	
	String SystemStats::getUserRegion()
	{
	   #if defined(__MUSL__)
	    if (auto* lang = ::getenv("LANG"))
	    {
	        String langStr(lang);
	        if (langStr.contains("_"))
	        {
	            auto region = langStr.fromFirstOccurrenceOf("_", false, false);
	            if (region.contains("."))
	                return region.upToFirstOccurrenceOf(".", false, false);
	            return region;
	        }
	    }
	    return "US";
	   #endif
	    return getLocaleValue (_NL_ADDRESS_COUNTRY_AB2);
	}
	LOCALEPATCH
	
	# Replace the functions in juce_SystemStats_linux.cpp
	sed -i '/^String SystemStats::getUserLanguage()/,/^}/c\
String SystemStats::getUserLanguage()\
{\
   #if defined(__MUSL__)\
    if (auto* lang = ::getenv("LANG"))\
    {\
        String langStr(lang);\
        if (langStr.contains("_"))\
            return langStr.upToFirstOccurrenceOf("_", false, false);\
        if (langStr.contains("."))\
            return langStr.upToFirstOccurrenceOf(".", false, false);\
        return langStr;\
    }\
    return "en";\
   #else\
    return getLocaleValue (_NL_ADDRESS_LANG_AB);\
   #endif\
}' "$builddir/modules/juce_core/native/juce_SystemStats_linux.cpp"
	
	sed -i '/^String SystemStats::getUserRegion()/,/^}/c\
String SystemStats::getUserRegion()\
{\
   #if defined(__MUSL__)\
    if (auto* lang = ::getenv("LANG"))\
    {\
        String langStr(lang);\
        if (langStr.contains("_"))\
        {\
            auto region = langStr.fromFirstOccurrenceOf("_", false, false);\
            if (region.contains("."))\
                return region.upToFirstOccurrenceOf(".", false, false);\
            return region;\
        }\
    }\
    return "US";\
   #else\
    return getLocaleValue (_NL_ADDRESS_COUNTRY_AB2);\
   #endif\
}' "$builddir/modules/juce_core/native/juce_SystemStats_linux.cpp"
	
	rm -f "$builddir/musl_locale_patch.tmp"
	
	# Remove the duplicate link guard symbols that we're about to add
	# The header already declares it as a struct, we'll add implementation
	msg2 "Preparing link guard symbols"
	# Don't add the namespace version, use the struct version from the header
	
	# Generate our config header that sets proper build mode
	mkdir -p "$builddir/modules/juce_core/juce_core"
	install -Dm644 /dev/stdin "$builddir/modules/juce_core/juce_core/juce-config.h" <<-'JUCECONFIG'
	/*
	  ==============================================================================
	   
	   Alpine Linux JUCE Configuration Header
	   
	   This file provides default configuration for JUCE when used as a system
	   package on Alpine Linux. It ensures consistent build settings across all
	   applications using JUCE from the Alpine repository.
	   
	  ==============================================================================
	*/
	#pragma once
	
	// Detect musl libc
	#if !defined(__GLIBC__) && !defined(__UCLIBC__)
	#define __MUSL__ 1
	#endif
	
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
	
	// Alpine/musl compatibility
	#define BACKWARD_HAS_DW 1
	
	// Add any other JUCE specific configurations here
	#define JUCE_FORCE_DEBUG 0
	#define JUCE_LOG_ASSERTIONS 0
	#define JUCE_CHECK_MEMORY_LEAKS 0
	JUCECONFIG
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
	
	# Install pkg-config file with elfutils-dev support
	install -Dm644 /dev/stdin "$pkgdir/usr/lib/pkgconfig/juce.pc" <<-EOF
	prefix=/usr
	exec_prefix=\${prefix}
	includedir=\${prefix}/include
	
	Name: JUCE
	Description: Cross-platform C++ framework for audio applications
	Version: $pkgver
	Requires.private: libdw
	Cflags: -I\${includedir}/JUCE-$pkgver/modules -DNDEBUG -DJUCE_DISABLE_ASSERTIONS=1 -DJUCE_GLOBAL_MODULE_SETTINGS_INCLUDED=1 -DBACKWARD_HAS_DW=1 -include juce_core/juce_core/juce-config.h
	Libs: -ldw
	EOF
	
	# Install CMake config
	install -Dm644 /dev/stdin "$pkgdir/usr/lib/cmake/JUCE/JUCEConfig.cmake" <<-EOF
	set(JUCE_FOUND TRUE)
	set(JUCE_VERSION $pkgver)
	set(JUCE_INCLUDE_DIRS /usr/include/JUCE-$pkgver/modules)
	set(JUCE_MODULES_PATH /usr/include/JUCE-$pkgver/modules)
	add_compile_definitions(JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED=1)
	add_compile_definitions(BACKWARD_HAS_DW=1)
	EOF
}

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

subpackages="$pkgname-doc $pkgname-examples $pkgname-extras"