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
# Because JUCE has a backend that was reliant upon depricated libexecinfo, now, we are required to use libdw from elfutils. 
prepare() {
	default_prepare
	if [ ! -d "$builddir/modules" ]; then
		error "modules directory missing in $builddir"
		return 1
	fi
	# Since execinfo.h doesn't properly exist in musl, we must backtrace properly via shim
	install -Dm644 /dev/stdin "$builddir/modules/juce_core/juce_core/execinfo.h" <<-'EXECINFO'
	#pragma once
	#ifdef __cplusplus
	extern "C" {
	#endif
	#if defined(__has_include)
	  #if __has_include(<elfutils/libdwfl.h>)
	  #endif
	#endif
	#ifndef _EXECINFO_H
	#define _EXECINFO_H 1
	// Pulling functions from libdw
	int backtrace(void **buffer, int size) __attribute__((weak));
	char **backtrace_symbols(void *const *buffer, int size) __attribute__((weak));
	void backtrace_symbols_fd(void *const *buffer, int size, int fd) __attribute__((weak));
	// Assign stub only if libdw isn't properly linked
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
	# Most common errors are with errno.h and execinfo.h
	# If something goes wrong, for example, we have another change to the Alpine Linux repo, consult here
	find "$builddir/modules" -type f \( -name "*.cpp" -o -name "*.h" \) -exec \
		sed -i 's|#include <sys/errno.h>|#include <errno.h>|g' {} \;
	sed -i 's|#include <execinfo.h>|#include "juce_core/execinfo.h"|g' \
		"$builddir/modules/juce_core/juce_core.cpp"
	find "$builddir/modules" -type f \( -name "*.cpp" -o -name "*.h" \) -exec \
		sed -i 's|#include <execinfo.h>|#include "juce_core/execinfo.h"|g' {} \;
	# Musl uses stat, no need to worry about 64-bit instantiations, it just is stat
	sed -i 's/struct stat64/struct stat/g' \
		"$builddir/modules/juce_core/native/juce_SharedCode_posix.h"
	sed -i 's/stat64/stat/g' \
		"$builddir/modules/juce_core/native/juce_SharedCode_posix.h"
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
	# Replace getUserRegion function
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
	# Configure the foundational header, so that it functions as a system package, it gives a needed consistency
	mkdir -p "$builddir/modules/juce_core/juce_core"
	install -Dm644 /dev/stdin "$builddir/modules/juce_core/juce_core/juce-config.h" <<-'JUCECONFIG'
	#pragma once
	// Musl swap
	#if !defined(__GLIBC__) && !defined(__UCLIBC__)
	#define __MUSL__ 1
	#endif
	// Set into release mode
	#ifndef NDEBUG
	#define NDEBUG
	#endif
	#ifndef _NDEBUG  
	#define _NDEBUG
	#endif
	// Additional JUCE settings
	#define JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED 1
	#define JUCE_STANDALONE_APPLICATION 1
	#define JUCE_USE_CURL 0
	#define JUCE_WEB_BROWSER 0
	#define JUCE_MODAL_LOOPS_PERMITTED 1
	#define BACKWARD_HAS_DW 1
	#define JUCE_FORCE_DEBUG 0
	#define JUCE_LOG_ASSERTIONS 0
	#define JUCE_CHECK_MEMORY_LEAKS 0
	JUCECONFIG
}

build() {
    BUILDLOG="/tmp/juce-build.log"
    exec 1> >(tee -a "$BUILDLOG")
    exec 2>&1
}

package() {
	install -dm755 "$pkgdir/usr/include/JUCE-$pkgver"
	cp -r "$builddir/modules" "$pkgdir/usr/include/JUCE-$pkgver/"
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
# Add subpackages related to docs, examples, and extras
subpackages="$pkgname-doc $pkgname-examples $pkgname-extras"