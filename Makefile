# ----- Makefile -----
#
BRANCH := $(shell git branch --show-current)
REMOTES := $(shell git remote)
VERSION := $(shell grep '^Version:' tildr.spec | awk '{print $$2}')
.DEFAULT_GOAL := help

.PHONY: help build install srpm lint version clean push push-lease

help:
	@echo "Options:"
	@echo
	@echo "  make build        -> Build the RPM package"
	@echo "  make install      -> Build and install the RPM package"
	@echo "  make srpm         -> Build source RPM"
	@echo "  make lint         -> Validate spec with rpmlint"
	@echo "  make version      -> Show current package version"
	@echo "  make clean        -> Clean all build files"
	@echo
	@echo "  make push         -> Performs a remote push to all branches"
	@echo "  make push-lease   -> Performs a remote push of all branches (lease mode)"

# ----- RPM BUILD -----
build:
	@bash tools/main.sh build

install:
	@bash tools/main.sh install

srpm:
	@bash tools/main.sh srpm

lint:
	@bash tools/main.sh lint

version:
	@echo "$(VERSION)"

clean:
	@bash tools/main.sh clean

# ----- GIT PUSH -----
push:
	@echo "Push normal → branch: $(BRANCH)"
	@for remote in $(REMOTES); do \
		echo "  pushing to $$remote..."; \
		git push $$remote $(BRANCH); \
	done

push-lease:
	@echo "Push --force-with-lease → branch: $(BRANCH)"
	@for remote in $(REMOTES); do \
		echo "  pushing to $$remote..."; \
		git push --force-with-lease $$remote $(BRANCH); \
	done
