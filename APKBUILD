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

# Because JUCE has a backend that was reliant upon deprecated libexecinfo, now, we are required to use libdw from elfutils. 
prepare() {
    default_prepare
    if [ ! -d "$builddir/modules" ]; then
        error "modules directory missing in $builddir"
        return 1
    fi
    # Pseduocode for webkit2gtk-4.1 upgrade - doesn't work, so if you wanna use it, you will need to patch this problem
    #find "$builddir/modules" -name "*.cmake" -type f -exec \
        #sed -i 's/webkit2gtk-4\.0/webkit2gtk-4.1/g' {} \;
    #find "$builddir/modules" -name "CMakeLists.txt" -type f -exec \
        #sed -i 's/webkit2gtk-4\.0/webkit2gtk-4.1/g' {} \;
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
    
    # Create locale compatibility header to provide missing constants
    install -Dm644 /dev/stdin "$builddir/modules/juce_core/native/locale_compat.h" <<-'LOCALE_COMPAT'
#pragma once

// Provide missing nl_item constants for musl
#ifndef _NL_ADDRESS_LANG_AB
#define _NL_ADDRESS_LANG_AB 0x1000
#endif

#ifndef _NL_ADDRESS_COUNTRY_AB2  
#define _NL_ADDRESS_COUNTRY_AB2 0x1001
#endif
LOCALE_COMPAT
    
    # Most common errors are with errno.h and execinfo.h
    find "$builddir/modules" -type f \( -name "*.cpp" -o -name "*.h" \) -exec \
        sed -i 's|#include <sys/errno.h>|#include <errno.h>|g' {} \;
    sed -i 's|#include <execinfo.h>|#include "juce_core/execinfo.h"|g' \
        "$builddir/modules/juce_core/juce_core.cpp"
    find "$builddir/modules" -type f \( -name "*.cpp" -o -name "*.h" \) -exec \
        sed -i 's|#include <execinfo.h>|#include "juce_core/execinfo.h"|g' {} \;
    
    # Add locale_compat.h include to the SystemStats file - use relative path
    local stats_file="$builddir/modules/juce_core/native/juce_SystemStats_linux.cpp"
    sed -i '1i #include "locale_compat.h"' "$stats_file"
    
    # Musl uses stat, no need to worry about 64-bit instantiations, it just is stat
    sed -i 's/struct stat64/struct stat/g' \
        "$builddir/modules/juce_core/native/juce_SharedCode_posix.h"
    sed -i 's/stat64/stat/g' \
        "$builddir/modules/juce_core/native/juce_SharedCode_posix.h"
    
    # Suppress locale related issues
    echo "=== DEBUG: Checking file content before modification ==="
    grep -A 10 -B 2 "String SystemStats::getUserLanguage()" "$stats_file" || true
    grep -A 10 -B 2 "String SystemStats::getUserRegion()" "$stats_file" || true
    
    # Use a Python script for more reliable patching
    cat > /tmp/fix_juce_locale.py << 'PYTHON_SCRIPT'
import sys

filename = sys.argv[1]
with open(filename, 'r') as f:
    content = f.read()

# Replace getUserLanguage function - match the actual BSD implementation
old_lang = '''String SystemStats::getUserLanguage()
{
   #if JUCE_BSD
    if (auto langEnv = getenv ("LANG"))
        return String::fromUTF8 (langEnv).upToLastOccurrenceOf (".UTF-8", false, true);

    return {};
   #else
    return getLocaleValue (_NL_ADDRESS_LANG_AB);
   #endif
}'''

new_lang = '''String SystemStats::getUserLanguage()
{
   #if JUCE_BSD || defined(__MUSL__)
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
}'''

# Replace getUserRegion function - match the actual BSD implementation
old_region = '''String SystemStats::getUserRegion()
{
   #if JUCE_BSD
    return {};
   #else
    return getLocaleValue (_NL_ADDRESS_COUNTRY_AB2);
   #endif
}'''

new_region = '''String SystemStats::getUserRegion()
{
   #if JUCE_BSD || defined(__MUSL__)
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
    return getLocaleValue (_NL_ADDRESS_COUNTRY_AB2);
   #endif
}'''

content = content.replace(old_lang, new_lang)
content = content.replace(old_region, new_region)

with open(filename, 'w') as f:
    f.write(content)

print("Successfully patched locale functions")
PYTHON_SCRIPT

    python3 /tmp/fix_juce_locale.py "$stats_file"
    
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
    
    # Build with minimal features - only the flags that are actually used
    cmake -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DJUCE_BUILD_EXTRAS=Off \
        -DJUCE_BUILD_EXAMPLES=Off \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON 2>&1 | \
        grep -v "webkit2gtk-4.0" | \
        grep -v "Package.*not found"
        
    cmake --build build --parallel $(nproc)
}

package() {
    install -dm755 "$pkgdir/usr/include/JUCE-$pkgver"
    cp -r "$builddir/modules" "$pkgdir/usr/include/JUCE-$pkgver/"
    if [ -d "$builddir/build" ]; then
        install -dm755 "$pkgdir/usr/lib"
        find "$builddir/build" \( -name "*.so" -o -name "*.so.*" -o -name "*.a" \) 2>/dev/null | while read -r lib; do
            if [ -f "$lib" ]; then
                install -Dm644 "$lib" "$pkgdir/usr/lib/$(basename "$lib")"
            fi
        done
    fi
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
	Libs: -L\${libdir} -ldw
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

# Note: webkit2gtk-4.0 is not included. It would not upgrade to 4.1, therefore, I've disabled it via grep
# Language modules have been disabled for now, due to their inability to be incorporated into Alpine properly