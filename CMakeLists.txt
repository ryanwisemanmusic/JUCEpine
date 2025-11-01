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
    NDEBUG
    _NDEBUG
    JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED=1
    BACKWARD_HAS_DW=1
)

find_library(JUCE_CORE_LIB NAMES juce_core libjuce_core PATHS /usr/lib /usr/local/lib)
find_library(JUCE_EVENTS_LIB NAMES juce_events libjuce_events PATHS /usr/lib /usr/local/lib)
find_library(JUCE_DATASTRUCTURES_LIB NAMES juce_data_structures libjuce_data_structures PATHS /usr/lib /usr/local/lib)

if(JUCE_CORE_LIB AND JUCE_EVENTS_LIB AND JUCE_DATASTRUCTURES_LIB)
    message(STATUS "Found JUCE shared libraries: ${JUCE_CORE_LIB}, ${JUCE_EVENTS_LIB}, ${JUCE_DATASTRUCTURES_LIB}")
    target_link_libraries(hello PRIVATE
        ${JUCE_CORE_LIB}
        ${JUCE_EVENTS_LIB}
        ${JUCE_DATASTRUCTURES_LIB}
        dw
        pthread
        dl
        asound
    )
else()
    message(WARNING "JUCE shared libraries not found - falling back to compiling JUCE module sources into the binary")

    set(JUCE_MODULES
        juce_core
        juce_events
        juce_data_structures
    )

    foreach(mod IN LISTS JUCE_MODULES)
        file(GLOB_RECURSE MOD_SRCS
            "${CMAKE_SOURCE_DIR}/JUCE/modules/${mod}/*.cpp"
            "${CMAKE_SOURCE_DIR}/JUCE/modules/${mod}/**/*.cpp"
        )
        if(MOD_SRCS)
            message(STATUS "Adding ${mod} sources (${MOD_SRCS})")
            target_sources(hello PRIVATE ${MOD_SRCS})
        else()
            message(WARNING "No sources found for JUCE module: ${mod}")
        endif()
    endforeach()

    target_link_libraries(hello PRIVATE
        dw
        pthread
        dl
        asound
    )
endif()

if(EXISTS "/usr/include/JUCE-${PROJECT_VERSION}")
    target_include_directories(hello PRIVATE /usr/include/JUCE-${PROJECT_VERSION}/modules)
endif()

target_include_directories(hello SYSTEM PRIVATE /usr/include/JUCE-7.0.8/modules)
