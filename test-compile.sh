#!/bin/bash
set -e

echo "=== Compiling Test Program ==="
cd /home/builder
ls -la && pwd && echo '---'

echo "Compiler flags:"
pkg-config --cflags juce

echo "Linker flags:"
pkg-config --libs juce

echo "Compiling..."
g++ -std=c++17 -DNDEBUG $(pkg-config --cflags juce) main.cpp /usr/include/JUCE-7.0.8/modules/juce_core/juce_core.cpp -o test_juce $(pkg-config --libs juce)

echo ""
echo "=== Running Test ==="
./test_juce

echo ""
echo "=== SUCCESS ==="