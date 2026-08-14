ARG FREEBSD_RELEASE
ARG JELLYFIN_FFMPEG_VERSION

FROM ghcr.io/daemonless/jellyfin-ffmpeg:${JELLYFIN_FFMPEG_VERSION} as jellyfin_ffmpeg
FROM ghcr.io/appjail-makejails/core:${FREEBSD_RELEASE}

ARG JELLYFIN_FFMPEG_VERSION
ARG NO_PKGCLEAN

LABEL org.opencontainers.image.title="Jellyfin" \
    org.opencontainers.image.description="Jellyfin Server Component with WebUI" \
    org.opencontainers.image.source="https://github.com/AppJail-makejails/jellyfin" \
    org.opencontainers.image.url="https://github.com/AppJail-makejails/jellyfin" \
    org.opencontainers.image.vendor="DtxdF" \
    org.opencontainers.image.authors="Jesús Daniel Colmenares Oviedo <dtxdf@disroot.org>"

RUN set -xe; \
    \
    pkg update; \
    pkg install \
        jellyfin \
        wqy-fonts \
        zh-CJKUnifonts \
        noto-sans-sc \
        noto-sans-tc \
        noto-sans-jp \
        noto-sans-kr \
        ja-font-ipa \
        ko-unfonts-core \
        libva \
        libva-intel-media-driver \
        gmmlib \
        mesa-dri \
        libass \
        libbluray \
        chromaprint \
        dav1d \
        fdk-aac \
        fontconfig \
        freetype2 \
        fribidi \
        gmp \
        harfbuzz \
        lame \
        libopenmpt \
        opus \
        libplacebo \
        shaderc \
        svt-av1 \
        libtheora \
        libvorbis \
        libvpx \
        vulkan-loader \
        webp \
        libx264 \
        x265 \
        sekrit-twc-zimg \
        libzvbi \
        gnutls \
        libxml2 \
        libiconv \
        libva \
        libdrm \
        libvdpau \
        libX11 \
        alsa-lib \
        sndio; \
    \
    if [ -z "${NO_PKGCLEAN}" ]; then \
        pkg clean -a; \
        rm -rf /var/cache/pkg/*; \
    fi; \
    rm -rf /var/db/pkg/repos/*

COPY --from=jellyfin_ffmpeg \
    /usr/local/bin/jellyfin-ffmpeg${JELLYFIN_FFMPEG_VERSION} \
    /usr/local/bin/jellyfin-ffprobe${JELLYFIN_FFMPEG_VERSION} \
    /usr/local/bin
COPY --from=jellyfin_ffmpeg /usr/local/lib/jellyfin-ffmpeg${JELLYFIN_FFMPEG_VERSION} \
    /usr/local/lib/jellyfin-ffmpeg${JELLYFIN_FFMPEG_VERSION}

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    JELLYFIN_DATA_DIR="/var/db/jellyfin" \
    JELLYFIN_CACHE_DIR="/var/cache/jellyfin" \
    JELLYFIN_CONFIG_DIR="/var/db/jellyfin/config" \
    JELLYFIN_LOG_DIR="/var/db/jellyfin/log" \
    JELLYFIN_WEB_DIR="/usr/local/jellyfin/jellyfin-web" \
    JELLYFIN_FFMPEG="/usr/local/bin/jellyfin-ffmpeg${JELLYFIN_FFMPEG_VERSION}"

# required for fontconfig cache
ENV XDG_CACHE_HOME=${JELLYFIN_CACHE_DIR}

# https://github.com/dlemstra/Magick.NET/issues/707#issuecomment-785351620
ENV MALLOC_TRIM_THRESHOLD_=131072

# https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(Native-GPU-Support)
ENV NVIDIA_VISIBLE_DEVICES="all"
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

ENV PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"

EXPOSE 8096
VOLUME ["${JELLYFIN_DATA_DIR}", "${JELLYFIN_CACHE_DIR}"]

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
