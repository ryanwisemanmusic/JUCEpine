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