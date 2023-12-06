# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntujammy

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# app title
ENV TITLE=KiCad

# Add FreeCAD PPA
RUN apt-get update && \
    apt-get install -y software-properties-common

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
    apt-get install -y \
    ocl-icd-libopencl1 \
    xz-utils && \
  ln -s libOpenCL.so.1 /usr/lib/x86_64-linux-gnu/libOpenCL.so && \
  # Get all of the remaining dependencies for the OS, VNC, and Kicad.
  apt-get update -y && \
  apt-get install -y --no-install-recommends lxterminal nano wget openssh-client rsync ca-certificates xdg-utils htop tar xzip gzip bzip2 zip unzip && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

RUN apt update && apt install -y --no-install-recommends --allow-unauthenticated \
        fonts-noto-core fonts-noto-hinted fonts-noto-ui-core libblosc1 \
        libboost-chrono1.74.0 libboost-filesystem1.74.0 libboost-iostreams1.74.0 \
        libboost-locale1.74.0 libboost-log1.74.0 libboost-regex1.74.0 \
        libboost-thread1.74.0 libglew2.2 libilmbase25 liblog4cplus-2.0.5 libnlopt0 *gtk3-0v5\
        libnotify4 libopenvdb8.1 libtbb2 libtbbmalloc2 libwxbase3.0-0v5 nautilus jq curl git \
    && add-apt-repository ppa:mozillateam/ppa \
    && apt update \
    && apt install firefox-esr -y \
    && apt autoclean -y \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Install KiCad

RUN rm -rf /var/lib/apt/lists/* \
  && apt-get autoclean \
  && mkdir -p /home/kasm-user/.config/kicad \
  && ln -s /home/kasm-user/.config/kicad /config/kicad \
  && chown -R kasm-user:kasm-user /config /home/kasm-user/.config/kicad \
  && chown -h kasm-user:kasm-user /config/kicad \
  && add-apt-repository ppa:kicad/kicad-7.0-releases \
  && apt update \
  && apt install kicad -y \
  && apt autoclean -y \
  && apt autoremove -y \
  && rm -rf /var/lib/apt/lists/*

# add local files
RUN if [ -f /defaults/menu.xml ]; then rm -rf /defaults/menu.xml; fi
COPY /root /

# ports and volumes
EXPOSE 3000
VOLUME /config
