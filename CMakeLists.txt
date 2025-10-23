cmake_minimum_required(VERSION 3.15)
project(HelloWorld)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

execute_process(
    COMMAND find /usr -name "juce_core.h" -type f 2>/dev/null | head -1
    OUTPUT_VARIABLE JUCE_HEADER_PATH
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

if(JUCE_HEADER_PATH)
    get_filename_component(JUCE_INCLUDE_DIR "${JUCE_HEADER_PATH}" DIRECTORY)
    get_filename_component(JUCE_INCLUDE_DIR "${JUCE_INCLUDE_DIR}" DIRECTORY)
    message(STATUS "Found JUCE headers at: ${JUCE_INCLUDE_DIR}")
else()
    set(JUCE_INCLUDE_DIR "/usr/include/JUCE-7.0.8/modules")
    message(WARNING "Could not auto-detect JUCE headers, using fallback: ${JUCE_INCLUDE_DIR}")
endif()

# Check if the directory actually exists
if(NOT EXISTS "${JUCE_INCLUDE_DIR}")
    message(FATAL_ERROR "JUCE headers not found at: ${JUCE_INCLUDE_DIR}")
endif()

add_executable(hello main.cpp)

target_include_directories(hello PRIVATE 
    ${JUCE_INCLUDE_DIR}
)

# Link basic system libraries
target_link_libraries(hello PRIVATE 
    stdc++fs
    pthread
)