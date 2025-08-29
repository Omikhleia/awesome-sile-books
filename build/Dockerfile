# ---------- BUILD STAGE BASE ----------
FROM ubuntu:24.10 AS build

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace

RUN apt-get update && apt-get install -y --no-install-recommends \
        # SYSTEM TOOLS
        # - ca-certificates: to ensure secure connections
        # - apt-transport-https: to allow APT to use HTTPS
        # - software-properties-common: to manage PPAs (and have add-apt-repository)
        ca-certificates \
        apt-transport-https \
        software-properties-common \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
        # DOWNLOAD & EXTRACTION TOOLS
        # - curl: for fetching font files in the Makefile-fonts, and graphviz installation
        # - xz-utils: for extracting the graphviz .tar.xz file
        # - libarchive-tools: for 'bsdtar' compatibility (used in the Makefile-fonts)
        curl \
        xz-utils \
        libarchive-tools \
        # - build-essential: for 'make' and 'gcc' later needed by luarocks for some packages
        build-essential \
        # LUA TOOLS & LUAJIT
        # - luajit: the pinned version of SILE uses it, so we want it too for consistency
        # - luarocks: needed to install resilient.sile and its dependencies
        # - git: needed by luarocks to fetch some packages
        luajit \
        luarocks \
        git \
        # DEPENDENCIES NEEDED BY RESILIENT.SILE (see documentation)
        # except graphiz see below (Problem 1)
        graphicsmagick \
        ghostscript \
        inkscape \
        lilypond \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Problem 1:
# The version of graphviz in the Ubuntu 24.10 repositories VERY old...
# So we go for a custom installation of a pinned version of Graphviz 13.1.2.
# We need the universe repository for some dependencies of graphviz.
RUN add-apt-repository universe \
 && apt-get update && \
    apt-get install -y curl xz-utils \
 && curl -fSL "https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/13.1.2/ubuntu_24.10_graphviz-13.1.2-debs.tar.xz" \
      -o graphviz.tar.xz \
 && tar -xJf graphviz.tar.xz \
 && apt-get install -y ./*.deb \
 && apt-get clean && rm -rf /var/lib/apt/lists/* graphviz.tar.xz ./*.deb \
 # Verify installation
 && dot -V

# ---------- FONTS STAGE ----------
FROM build AS fonts

WORKDIR /workspace

# Add curated set of decent fonts for examples
# The makefile will download and install them in .fonts/
COPY ./build/Makefile-fonts ./
RUN make -f Makefile-fonts allfonts

# ---------- STAGE SILE ----------
FROM build AS sile

WORKDIR /workspace

# Add the SILE PPA repository and install SILE
# software-properties-common is needed to manage PPAs (and have add-apt-repository)
# SILE is then pinned to version 0.15.13
RUN add-apt-repository ppa:sile-typesetter/sile && apt-get update && apt-cache policy sile \
 && apt-get update && apt-get install -y sile=0.15.13-1ppa1~ubuntu24.10 \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 # Verify installation
 # For reference I got: SILE v0.15.13 (LuaJIT 2.1.1719379426) [Rust]
 && sile --version

# Check the Lua version used by SILE and set it as the default for LuaRocks
RUN sile -q -e 'print(SILE.lua_version); os.exit()' > /tmp/LVER \
 && luarocks config lua_version $(cat /tmp/LVER) \
 # Verify
 && luarocks list

# Problem 2:
# We would expect here to see all Lua dependencies used by SILE,
# but they don't show up.
# With an Arch Linux base image, it worked...
# Worse, some dependencies seem old (e.g. lpeg 1.0.2)...
# So enforce installation of the dependencies in versions needed by SILE.
# Some will need compilation, and development headers...
RUN apt-get update && apt-get install -y --no-install-recommends \
        zlib1g-dev \
        libexpat1-dev \
        libssl-dev \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && luarocks install --only-deps --dev sile \
 && luarocks list

# Resilient packages and classes for SILE
# Yay, at last!
RUN luarocks install resilient.sile && luarocks list

# Copy the fonts we installed in the fonts stage
COPY --from=fonts /workspace/.fonts /.fonts

WORKDIR /data
ENTRYPOINT ["sile"]
