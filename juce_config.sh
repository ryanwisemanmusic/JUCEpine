#!/bin/sh

# juce_config.sh - JUCE configuration header setup

create_juce_config_header() {
    local builddir="$1"
    
    mkdir -p "$builddir/modules/juce_core/juce_core"
    install -Dm644 /dev/stdin "$builddir/modules/juce_core/juce_core/juce-config.h" <<-'JUCECONFIG'
#pragma once
// Musl detection
#if !defined(__GLIBC__) && !defined(__UCLIBC__)
#define __MUSL__ 1
#endif
// Release mode
#ifndef NDEBUG
#define NDEBUG
#endif
#ifndef _NDEBUG  
#define _NDEBUG
#endif
// JUCE settings
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