FROM docker.io/library/archlinux:base

# Cleanup of pacman database and cache so layer size stays small at each step
RUN pacman --noconfirm -Syuq && yes | pacman -Sccq

# Install the necessary components and clean up the cache
RUN pacman --needed --noconfirm -S \
    # make (used by the Makefile-fonts)
    make \
    # LuaRocks
    luarocks \
    git \
    # SILE
    sile \
    # Additional tools used by some of the resilient modules
    graphicsmagick \
    ghostscript \
    graphviz \
    inkscape \
    lilypond \
    && yes | pacman -Sccq

# Curated set of decent fonts for examples
COPY ./build/Makefile-fonts /
RUN make -f Makefile-fonts allfonts

# Just to check the version on first run
RUN sile --version

# Check the Lua version used by SILE
# And set it as the default for LuaRocks
RUN sile -q -e 'print(SILE.lua_version); os.exit()' > /tmp/LVER
RUN luarocks config lua_version $(cat /tmp/LVER)

# Resilient packages and classes for SILE
RUN luarocks install resilient.sile
RUN luarocks list

WORKDIR /data
ENTRYPOINT ["sile"]
