#!/bin/sh

# cmake_eof.sh - JUCE CMake configuration file generation

create_cmake_config() {
    local pkgdir="$1"
    local pkgver="$2"
    
    # Create CMake config with all modules
    install -dm755 "$pkgdir/usr/lib/cmake/JUCE"
    install -Dm644 /dev/stdin "$pkgdir/usr/lib/cmake/JUCE/JUCEConfig.cmake" <<-EOF
set(JUCE_FOUND TRUE)
set(JUCE_VERSION $pkgver)
set(JUCE_INCLUDE_DIRS /usr/include/JUCE-$pkgver/modules)
set(JUCE_MODULES_PATH /usr/include/JUCE-$pkgver/modules)
set(JUCE_LIBRARIES 
    juce_audio_plugin_client
    juce_audio_utils
    juce_audio_processors 
    juce_audio_formats 
    juce_audio_devices 
    juce_audio_basics 
    juce_dsp
    juce_gui_extra
    juce_gui_basics 
    juce_graphics 
    juce_opengl
    juce_video
    juce_osc
    juce_cryptography
    juce_analytics
    juce_box2d
    juce_product_unlocking
    juce_data_structures 
    juce_events 
    juce_core
)
add_compile_definitions(JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED=1)
add_compile_definitions(BACKWARD_HAS_DW=1)
EOF
}