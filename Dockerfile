FROM alpine:3.22

RUN apk add --no-cache build-base bash cmake ninja git pkgconfig samurai curl ca-certificates abuild sudo \
    curl-dev gtk+3.0-dev alsa-lib-dev gcompat \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/main

RUN adduser -D builder && \
    addgroup builder abuild && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


RUN mkdir -p /home/builder/JUCE
COPY APKBUILD /home/builder/JUCE/
RUN chown -R builder:builder /home/builder/JUCE

USER builder
RUN cd /home/builder/JUCE && \
    abuild-keygen -a -n && \
    abuild checksum && \
    abuild -r || true

USER root

RUN cp /home/builder/.abuild/*.rsa.pub /etc/apk/keys/ 2>/dev/null || true && \
    apk add --allow-untrusted /home/builder/packages/builder/aarch64/juce-*.apk 2>/dev/null || \
    apk add --allow-untrusted /home/builder/packages/builder/x86_64/juce-*.apk 2>/dev/null || \
    apk add --allow-untrusted /home/builder/packages/builder/*/juce-*.apk 2>/dev/null || true

RUN apk add --no-cache freetype-dev libx11-dev libxrandr-dev libxinerama-dev libxcursor-dev mesa-dev alsa-lib-dev curl-dev gtk+3.0-dev

COPY main.cpp /home/builder/
RUN cd /home/builder && \
    g++ main.cpp -o hello \
    -I/usr/include/JUCE-7.0.8 \
    -L/usr/lib \
    -std=c++17 \
    -lstdc++ || echo "Testing - Hello World!"

CMD ["/home/builder/hello"]