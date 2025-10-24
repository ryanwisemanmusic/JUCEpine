FROM alpine:3.22 AS final

# Install runtime dependencies and build tools for test compilation
RUN apk update && \
    apk add --no-cache freetype libx11 libxrandr libxinerama libxcursor mesa alsa-lib curl gtk+3.0 ca-certificates build-base

# Copy the JUCE headers and shared artifacts built by APKBUILD
COPY packages/juce/usr/ /usr/

# Simple test binary
COPY main.cpp /home/builder/main.cpp
WORKDIR /home/builder
RUN g++ -I/usr/include main.cpp -o test_juce

CMD ["./test_juce"]
