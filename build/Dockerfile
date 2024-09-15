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

# Curated set of decent fonts for examples
RUN pacman --noconfirm -S make
COPY ./build/Makefile-fonts /
RUN make -f Makefile-fonts allfonts

# Just to check the version on first run
RUN sile --version

# Resilient packages and classes for SILE
# Try to deduce the Lua version used by SILE, which might be different from the system Lua
RUN v=$(sile --quiet -e 'print(SILE.lua_version); os.exit()'); echo $v > /LVER
RUN luarocks install --lua-version $(cat /LVER) resilient.sile
RUN luarocks list --lua-version $(cat /LVER)

WORKDIR /data
ENTRYPOINT ["sile"]
