cmake_minimum_required(VERSION 3.16)
project(HelloWorld)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG" CACHE STRING "Release flags" FORCE)

add_executable(hello main.cpp)

target_include_directories(hello PRIVATE
    ${CMAKE_SOURCE_DIR}/JUCE
    ${CMAKE_SOURCE_DIR}/JUCE/modules
)

target_compile_options(hello PRIVATE
    -O3
    -DNDEBUG
    -D_NDEBUG
    -fno-exceptions
)

target_compile_definitions(hello PRIVATE
    JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED=1
    JUCE_MODAL_LOOPS_PERMITTED=1
    JUCE_MODULE_AVAILABLE_juce_core=1
    JUCE_STANDALONE_APPLICATION=1
    NDEBUG=1
    _NDEBUG=1
    JUCE_DISABLE_NATIVE_FILECHOOSER=1
    JUCE_DISABLE_ASSERTIONS=1
)

target_link_libraries(hello PRIVATE
    pthread
    dl
    asound
)
