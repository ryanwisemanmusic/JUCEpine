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
    abuild -r

USER root

RUN cp /home/builder/.abuild/*.rsa.pub /etc/apk/keys/
RUN apk add --allow-untrusted /home/builder/packages/*/juce-*.apk

COPY main.cpp /home/builder/
RUN g++ /home/builder/main.cpp -o /home/builder/hello -ljuce

CMD ["/bin/sh"]