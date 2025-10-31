FROM alpine:3.22 AS final

RUN apk add --no-cache \
    bash git freetype-dev libx11-dev libxrandr-dev libxinerama-dev \
    libxcursor-dev mesa-dev gtk+3.0-dev alsa-lib-dev curl-dev gcompat \
    musl-dev \
    doas cmake ninja python3 unzip abuild build-base elfutils-dev \
    # I need to patch webkit2gtk-4.0 to 1, but so far, haven't found a valid APKBUILD way of doing this
    curl gtk+3.0 ca-certificates wget webkit2gtk-4.1

RUN adduser -D -G abuild builder && \
    echo "permit nopass builder as root" > /etc/doas.conf

WORKDIR /home/builder

COPY --chown=builder:builder APKBUILD 7.0.8.tar.gz *.patch ./

COPY --chown=builder:builder build-setup.sh docker-entrypoint.sh test-compile.sh ./
RUN chmod +x /home/builder/build-setup.sh /home/builder/docker-entrypoint.sh /home/builder/test-compile.sh

COPY --chown=builder:builder main.cpp link_guard_stub.cpp execinfo.h ./

USER builder

ENTRYPOINT ["/bin/bash", "/home/builder/docker-entrypoint.sh"]

CMD ["/bin/bash", "/home/builder/build-setup.sh"]