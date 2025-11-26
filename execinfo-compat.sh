#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-only
#
# execinfo-compat.sh - Fulfills the missing backtrace requirements that only exist under glibc, 
#                      since libexecinfo was deprecated (and JUCE requires musl-compliant backtrace)
# Copyright (C) 2025 Ryan Wiseman
install -Dm644 /dev/stdin "$builddir/modules/juce_core/juce_core/execinfo.h" <<'EOF'
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
int backtrace(void **buffer, int size) __attribute__((weak));
char **backtrace_symbols(void *const *buffer, int size) __attribute__((weak));
void backtrace_symbols_fd(void *const *buffer, int size, int fd) __attribute__((weak));

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
EOF

# Fix execinfo.h includes throughout JUCE modules
find "$builddir/modules" -type f \( -name "*.cpp" -o -name "*.h" \) -exec \
    sed -i 's|#include <execinfo.h>|#include "juce_core/execinfo.h"|g' {} \;
