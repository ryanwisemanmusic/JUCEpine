#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-only
#
# locale_compat.sh - Provides the missing locale constants for musl (may need tweaking)
# Copyright (C) 2025 Ryan Wiseman
create_locale_compat_header() {
    local builddir="$1"
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
}
