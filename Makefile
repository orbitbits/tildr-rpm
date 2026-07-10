# ----- Makefile -----
#
BRANCH := $(shell git branch --show-current)
REMOTES := $(shell git remote)
.DEFAULT_GOAL := help

.PHONY: help build install clean push push-lease

help:
	@echo "Options:"
	@echo
	@echo "  make build        -> Build the RPM package"
	@echo "  make install      -> Build and install the RPM package"
	@echo "  make clean        -> Clean all build files"
	@echo
	@echo "  make push         -> Performs a remote push to all branches"
	@echo "  make push-lease   -> Performs a remote push of all branches (lease mode)"

# ----- RPM BUILD -----
build:
	@bash tools/main.sh build

install:
	@bash tools/main.sh install

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
