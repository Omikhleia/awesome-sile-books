FROM ubuntu:24.10

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies:
# - ca-certificates: to ensure secure connections
# - apt-transport-https: to allow APT to use HTTPS
# - curl: for fetching font files in the Makefile-fonts
# - build-essential: for 'make' and 'gcc' later if needed by luarocks
# - libarchive-tools: for 'bsdtar' compatibility (used in the Makefile-fonts)
# - software-properties-common: to manage PPAs (and have add-apt-repository)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    apt-transport-https \
    curl \
    build-essential \
    libarchive-tools \
    software-properties-common

# Add curated set of decent fonts for examples
COPY ./build/Makefile-fonts /
RUN make -f Makefile-fonts allfonts

# Add the SILE PPA repository
# software-properties-common is needed to manage PPAs (and have add-apt-repository)
RUN add-apt-repository ppa:sile-typesetter/sile && apt-get update && apt-cache policy sile

# Install SILE (pinning the version to 0.15.13)
# and all other dependencies needed by the resilient collection
RUN apt-get install -y --no-install-recommends \
    sile=0.15.13-1ppa1~ubuntu24.10 \
    graphicsmagick \
    ghostscript \
    graphviz \
    inkscape \
    lilypond \
    luajit \
    git \
    luarocks \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Just to check that SILE runs
# For reference I got: SILE v0.15.13 (LuaJIT 2.1.1719379426) [Rust]
RUN echo "SILE version"
RUN sile --version

# Check the Lua version used by SILE and set it as the default for LuaRocks
# We expect it to be 5.1 here as SILE above reported using LuaJIT 2.1), but
# let's be safe.
RUN sile -q -e 'print(SILE.lua_version); os.exit()' > /tmp/LVER
RUN luarocks config lua_version $(cat /tmp/LVER)

# We would expet here to see all Lua dependencies used by SILE
# With an Arch Linux base image, it worked.
# I don't know how SILE for Ubuntu is built, but the list is empty here.
# The consequence is that resilient.sile's own dependencies will install
# their own versions of Penlight, lpeg, luafilesystem, etc.
# The latter (at least) requires compilation, so we still need build-essential...
# RUN luarocks list

# Resilient packages and classes for SILE
# Yay, at last!
RUN luarocks install resilient.sile
# RUN luarocks list

# Remove some no longer needed packages
# This wont make the image smaller (due to the way Docker layers work),
# but it will make the image a bit cleaner
RUN apt-get purge -y --auto-remove \
    curl \
    gnupg \
    software-properties-common \
    build-essential \
    libarchive-tools \
 && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /data
ENTRYPOINT ["sile"]
