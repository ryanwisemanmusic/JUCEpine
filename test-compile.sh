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

CFGS=$(pkg-config --cflags juce)
LIBS_RAW=$(pkg-config --libs juce)

filtered_libs=()
for token in $LIBS_RAW; do
	if [[ "$token" == -l* ]]; then
		name="${token:2}"
		if [ -e "/usr/lib/lib${name}.a" ] || ls /usr/lib/lib${name}.so* > /dev/null 2>&1; then
			filtered_libs+=("$token")
		else
			echo "[test-compile] skipping $token (library not found in /usr/lib)"
		fi
	else
		filtered_libs+=("$token")
	fi
done

LINK_FLAGS="${filtered_libs[*]}"
echo "Using linker flags: $LINK_FLAGS"

g++ -std=c++17 -DNDEBUG $CFGS main.cpp -o test_juce $LINK_FLAGS

echo ""
echo "=== Running Test ==="
./test_juce

echo ""
echo "=== SUCCESS ==="