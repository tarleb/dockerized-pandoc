Dockerized pandoc
=================

Dockerfiles for pandoc. This repo contains various Dockerfiles which
build and bundle pandoc.  The goal is to provide images which

  - contain the latest versions of pandoc and pandoc-citeproc,
  - use distribution-specific tools for building,
  - allow to use pandoc with Lua C libraries, and
  - are easy to use.

Example usage:

    docker run tarleb/alpine-pandoc -v $(pwd):/data INPUT-FILE.md

Note: Debian images are not yet available on Docker Hub.
