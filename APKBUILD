# Contributor: Ryan Wiseman <ryanwisemanmusic@gmail.com>
# Maintainer: Ryan Wiseman <ryanwisemanmusic@gmail.com>
mkdir -p "$srcdir" || true
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
fetch() {
    echo ">>> juce: Starting download..."
    
    if command -v wget >/dev/null 2>&1; then
        echo ">>> Using wget (BusyBox compatible)..."
        wget -T 60 -O "$SRCDEST/juce-$pkgver.tar.gz" \
             "https://github.com/juce-framework/JUCE/archive/refs/tags/$pkgver.tar.gz" && return 0
    fi
    
    if command -v curl >/dev/null 2>&1; then
        echo ">>> Using curl..."
        curl -L --connect-timeout 30 --max-time 120 \
             -o "$SRCDEST/juce-$pkgver.tar.gz" \
             "https://github.com/juce-framework/JUCE/archive/refs/tags/$pkgver.tar.gz" && return 0
    fi
    
    echo ">>> Trying default fetch..."
    default_fetch && return 0
    
    if [ -f "7.0.8.tar.gz" ]; then
        echo ">>> Using local tarball as last resort: 7.0.8.tar.gz"
        cp "7.0.8.tar.gz" "$SRCDEST/juce-$pkgver.tar.gz" && return 0
    fi
    
    echo ">>> ERROR: All download methods failed!"
    return 1
}
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
	
	# FIX: Completely replace the problematic SystemStats functions
	cat > "$builddir/modules/juce_core/native/juce_SystemStats_linux.cpp" << 'SYSTEMSTATS_FIX'
#include "juce_core/juce_core.h"
#include <sys/utsname.h>
#include <sys/sysinfo.h>
#include <unistd.h>
#include <cstdlib>

namespace juce
{

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
    return "en"; // Fallback for non-musl
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
   #else
    return "US"; // Fallback for non-musl
   #endif
}

// Keep the rest of the original file content
SYSTEMSTATS_FIX

	# Append the rest of the original file (excluding the problematic functions)
	tail -n +40 "$builddir/modules/juce_core/native/juce_SystemStats_linux.cpp.orig" 2>/dev/null || \
	tail -n +40 "$builddir/modules/juce_core/native/juce_SystemStats_linux.cpp" >> "$builddir/modules/juce_core/native/juce_SystemStats_linux.cpp"
	
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
    
    cd "$builddir"
    
    # Build with ALL optional features disabled
    cmake -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DJUCE_BUILD_EXTRAS=Off \
        -DJUCE_BUILD_EXAMPLES=Off \
        -DJUCE_SHARED_CODE=ON \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DJUCE_USE_CURL=Off \
        -DJUCE_WEB_BROWSER=Off \
        -DJUCE_USE_MP3AUDIOFORMAT=Off \
        -DJUCE_USE_OGGVORBIS=Off \
        -DJUCE_USE_FLAC=Off \
        -DJUCE_USE_FFMPEG=Off \
        -DJUCE_USE_OPENGL=Off \
        -DJUCE_ENABLE_MODULE_VERSIONING=Off \
        -DCMAKE_FIND_DEBUG_MODE=ON 
    cmake --build build --parallel
}

package() {
    # Install headers (keep your existing header setup)
    install -dm755 "$pkgdir/usr/include/JUCE-$pkgver"
    cp -r "$builddir/modules" "$pkgdir/usr/include/JUCE-$pkgver/"
    
    # Install built libraries
    install -dm755 "$pkgdir/usr/lib"
    find "$builddir/build" -name "*.so" -o -name "*.so.*" -o -name "*.a" | while read -r lib; do
        install -Dm644 "$lib" "$pkgdir/usr/lib/"
    done
    
    # Update pkg-config to include JUCE libraries
    install -Dm644 /dev/stdin "$pkgdir/usr/lib/pkgconfig/juce.pc" <<-EOF
prefix=/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include
Name: JUCE
Description: Cross-platform C++ framework for audio applications
Version: $pkgver
Requires.private: libdw
Cflags: -I\${includedir}/JUCE-$pkgver/modules -DNDEBUG -DJUCE_DISABLE_ASSERTIONS=1 -DJUCE_GLOBAL_MODULE_SETTINGS_INCLUDED=1 -DBACKWARD_HAS_DW=1 -include juce_core/juce_core/juce-config.h
Libs: -L\${libdir} -ljuce_core -ljuce_events -ljuce_audio_basics -ljuce_gui_basics -ljuce_graphics -ldw
EOF
    
    # Update CMake config to include libraries
    install -Dm644 /dev/stdin "$pkgdir/usr/lib/cmake/JUCE/JUCEConfig.cmake" <<-EOF
set(JUCE_FOUND TRUE)
set(JUCE_VERSION $pkgver)
set(JUCE_INCLUDE_DIRS /usr/include/JUCE-$pkgver/modules)
set(JUCE_MODULES_PATH /usr/include/JUCE-$pkgver/modules)
set(JUCE_LIBRARIES juce_core juce_events juce_audio_basics juce_gui_basics juce_graphics)
add_compile_definitions(JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED=1)
add_compile_definitions(BACKWARD_HAS_DW=1)

# Imported targets for each JUCE module
foreach(lib \${JUCE_LIBRARIES})
    add_library(juce::\${lib} SHARED IMPORTED)
    set_target_properties(juce::\${lib} PROPERTIES
        IMPORTED_LOCATION "/usr/lib/lib\${lib}.so"
        INTERFACE_INCLUDE_DIRECTORIES "\${JUCE_INCLUDE_DIRS}"
    )
endforeach()
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