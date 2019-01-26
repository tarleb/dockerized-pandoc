FROM debian:buster-slim AS buster-pandoc-haskell

ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_PRIORITY critical

RUN apt-get -q --no-allow-insecure-repositories update && \
    apt-get install --assume-yes --no-install-recommends \
      ca-certificates \
      cabal-install \
      cpp \
      curl \
      fakeroot \
      gcc \
      ghc \
      git \
      libghc-aeson-dev \
      libghc-aeson-pretty-dev \
      libghc-base64-bytestring-dev \
      libghc-blaze-html-dev \
      libghc-cmark-gfm-dev \
      libghc-data-default-dev \
      libghc-doctemplates-dev \
      libghc-exceptions-dev \
      libghc-file-embed-dev \
      libghc-glob-dev \
      libghc-haddock-library-dev \
      libghc-hs-bibutils-dev \
      libghc-hsyaml-dev \
      libghc-http-client-tls-dev \
      libghc-http-dev \
      libghc-juicypixels-dev \
      libghc-pandoc-types-dev \
      libghc-safe-dev \
      libghc-setenv-dev \
      libghc-sha-dev \
      libghc-skylighting-dev \
      libghc-split-dev \
      libghc-syb-dev \
      libghc-tagsoup-dev \
      libghc-temporary-dev \
      libghc-texmath-dev \
      libghc-text-icu-dev \
      libghc-unicode-transforms-dev \
      libghc-xml-conduit-dev \
      libghc-yaml-dev \
      libghc-zip-archive-dev \
      libghc-zlib-dev \
      make \
      zlib1g-dev \
    && \
    apt-get clean

WORKDIR /app

RUN cabal update

FROM buster-pandoc-haskell AS buster-pandoc-build

# Ensure artifacts folder exists
WORKDIR /artifacts

WORKDIR /app

# get sources
RUN git clone --depth 1 https://github.com/jgm/pandoc
RUN git clone --depth 1 https://github.com/jgm/pandoc-citeproc

# build pandoc
WORKDIR /app/pandoc
RUN  cabal install --only-dep \
  && cabal configure --flag embed_data_files \
  && cabal build --ghc-options '-O2 -optl=-pthread -fPIC' \
  && cabal copy \
  && cabal register \
  && cp dist/build/pandoc/pandoc /artifacts \
  && strip /artifacts/pandoc
WORKDIR /app/pandoc-citeproc
RUN cabal configure --flag unicode_collation \
                    --flag bibutils \
                    --flag embed_data_files \
  && cabal build --ghc-options '-O2 -optl=-pthread -fPIC' \
  && cabal copy \
  && cp dist/build/pandoc-citeproc/pandoc-citeproc /artifacts \
  && strip /artifacts/pandoc-citeproc

WORKDIR /app/pandoc
RUN linux/make_deb.sh

FROM debian:buster-slim AS buster-slim-pandoc

ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_PRIORITY critical

# We are not using the system-wide installed Lua, allow HsLua to find
# Debian Lua libraries.
ENV LUA_PATH "/usr/share/lua/5.3/?.lua;??"
ENV LUA_CPATH "/usr/lib/x86_64-linux-gnu/lua/5.3/?.so;??"

COPY --from=buster-pandoc-build \
  /artifacts/pandoc /artifacts/pandoc-citeproc \
  /usr/bin/

RUN apt-get -q --no-allow-insecure-repositories update \
  && apt-get install --assume-yes --no-install-recommends \
       libatomic1 \
       libbibutils6 \
       libicu63 \
       libpcre3 \
       libyaml-0-2 \
       zlib1g \
  && rm -rf /var/lib/apt/lists/*
