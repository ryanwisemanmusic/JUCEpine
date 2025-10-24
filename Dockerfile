FROM alpine:3.22 AS final

RUN apk add --no-cache \
    bash git freetype-dev libx11-dev libxrandr-dev libxinerama-dev \
    libxcursor-dev mesa-dev gtk+3.0-dev alsa-lib-dev curl-dev gcompat \
    doas cmake ninja python3 unzip abuild build-base \
    curl gtk+3.0 ca-certificates

RUN adduser -D -G abuild builder

WORKDIR /home/builder

COPY APKBUILD 7.0.8.tar.gz ./
COPY main.cpp .

CMD ["./test_juce"]
