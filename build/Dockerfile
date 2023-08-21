#syntax=docker/dockerfile:1.2

FROM docker.io/library/archlinux:base

RUN pacman --needed --noconfirm -Syu

# SILE
RUN pacman --noconfirm -S sile

# Luarocks
RUN pacman --noconfirm -S luarocks git

# Additional tools used by some of the resilient modules
RUN pacman --noconfirm -S graphicsmagick
RUN pacman --noconfirm -S inkscape
RUN pacman --noconfirm -S ghostscript
RUN pacman --noconfirm -S graphviz
RUN pacman --noconfirm -S lilypond

# Resilient packages and classes for SILE
RUN luarocks install resilient.sile

# Curated set of decent fonts for examples
RUN pacman --noconfirm -S make
COPY ./build/Makefile-fonts /
RUN make -f Makefile-fonts allfonts
# COPY ./build/fonts/OCRB.otf /.fonts

# Should be done
RUN luarocks list
RUN sile --version

WORKDIR /data
ENTRYPOINT ["sile"]
