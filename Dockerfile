FROM alpine:3.22 AS builder

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update

RUN apk add --no-cache build-base bash git curl ca-certificates \
    freetype-dev libx11-dev libxrandr-dev libxinerama-dev libxcursor-dev mesa-dev \
    gtk+3.0-dev alsa-lib-dev curl-dev gcompat abuild doas

RUN adduser -D builder
WORKDIR /home/builder
USER builder
ENV HOME=/home/builder

WORKDIR /home/builder/JUCE
COPY . /home/builder/JUCE
RUN mkdir -p /home/builder/JUCE/usr/include /home/builder/JUCE/usr/share && \
    chown -R builder:builder /home/builder/JUCE/usr

RUN mkdir -p /home/builder/JUCE/usr/include && \
    if [ -d modules ]; then cp -rv modules /home/builder/JUCE/usr/include/JUCE; fi && \
    if [ -f extras/BinaryBuilder/JuceLibraryCode/JuceHeader.h ]; then \
        cp -v extras/BinaryBuilder/JuceLibraryCode/JuceHeader.h /home/builder/JUCE/usr/include/; \
    fi && \
    mkdir -p /home/builder/JUCE/usr/include/JUCE-7.0.8 && \
    if [ -d modules ]; then cp -rv modules /home/builder/JUCE/usr/include/JUCE-7.0.8/; fi && \
    ln -sfv JUCE-7.0.8 /home/builder/JUCE/usr/include/JUCE

RUN mkdir -p /home/builder/JUCE/usr/share/juce && \
    if [ -d extras ]; then cp -rv extras /home/builder/JUCE/usr/share/juce/; fi && \
    if [ -d examples ]; then cp -rv examples /home/builder/JUCE/usr/share/juce/; fi

USER root
RUN mkdir -p /artifacts && \
    cp -rv /home/builder/JUCE/usr/include /artifacts/ && \
    cp -rv /home/builder/JUCE/usr/share /artifacts/ && \
    if [ -d /home/builder/JUCE/usr/lib/cmake ]; then \
        mkdir -p /artifacts/lib && \
        cp -rv /home/builder/JUCE/usr/lib/cmake /artifacts/lib/; \
    fi

USER builder
WORKDIR /home/builder

RUN abuild-keygen -a -i -n

RUN abuild -r -P


FROM alpine:3.22 AS final

RUN apk update && \
    apk add --no-cache build-base freetype-dev libx11-dev libxrandr-dev libxinerama-dev libxcursor-dev mesa-dev \
    alsa-lib-dev curl-dev gtk+3.0-dev ca-certificates

COPY --from=builder /artifacts/include /usr/include
COPY --from=builder /artifacts/share /usr/share

COPY main.cpp /home/builder/main.cpp
WORKDIR /home/builder

RUN g++ -I/usr/include main.cpp -o test_juce

CMD ["./test_juce"]

