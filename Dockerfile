FROM alpine:3.22 AS final

# Install runtime dependencies and build tools for test compilation
RUN apk update && \
    apk add --no-cache freetype libx11 libxrandr libxinerama libxcursor mesa alsa-lib curl gtk+3.0 ca-certificates build-base

# Copy APKBUILD and source for testing
COPY APKBUILD /home/builder/APKBUILD
COPY 7.0.8.tar.gz /home/builder/7.0.8.tar.gz

# Run APKBUILD to see the output
RUN apk add --no-cache abuild sudo && \
    adduser -D -G abuild builder && \
    mkdir -p /var/cache/distfiles && \
    chmod 777 /var/cache/distfiles && \
    chown -R builder:abuild /home/builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

WORKDIR /home/builder
RUN su builder -c "abuild-keygen -a -n" && \
    su builder -c "cd /home/builder && abuild 2>&1" | tee /tmp/abuild.log || true

# Copy the JUCE headers and shared artifacts built by APKBUILD
COPY packages/juce/usr/ /usr/

# Simple test binary
COPY main.cpp /home/builder/main.cpp
RUN g++ -I/usr/include main.cpp -o test_juce

# Show APKBUILD output and run test
CMD sh -c "echo '=== APKBUILD Output ===' && cat /tmp/abuild.log 2>/dev/null || echo 'No abuild log found' && echo '' && echo '=== Running Test ===' && ./test_juce"
