PANDOC_VERSION ?= dev

ifeq ($(PANDOC_VERSION),dev)
PANDOC_COMMIT          ?= master
PANDOC_CITEPROC_COMMIT ?= master
else
PANDOC_COMMIT          ?= $(PANDOC_VERSION)
PANDOC_CITEPROC_COMMIT ?= 0.15.0.1
endif

build-debian:
	docker build \
	    --tag tarleb/buster-slim-pandoc:$(PANDOC_VERSION) \
	    --build-arg pandoc_commit=$(PANDOC_COMMIT) \
	    --build-arg pandoc_citeproc_commit=$(PANDOC_CITEPROC_COMMIT) \
	    debian

build-alpine:
	docker build \
	    --tag tarleb/alpine-pandoc:$(PANDOC_VERSION) \
	    --build-arg pandoc_commit=$(PANDOC_COMMIT) \
	    --build-arg pandoc_citeproc_commit=$(PANDOC_CITEPROC_COMMIT) \
	    alpine

show-args:
	@printf "PANDOC_VERSION (i.e. image version tag): %s\n" $(PANDOC_VERSION)
	@printf "pandoc_commit=%s\n" $(PANDOC_COMMIT)
	@printf "pandoc_citeproc_commit=%s\n" $(PANDOC_CITEPROC_COMMIT)

.PHONY: show-args
