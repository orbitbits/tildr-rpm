<!-- markdownlint-disable MD033 -->
<!-- markdownlint-disable MD041 -->

<p align="center">
  <img style="border-radius: 5px;" src="https://raw.githubusercontent.com/orbitbits/tildr/refs/heads/main/.github/brand/logo-text/compact/tildr-variation-3.svg" alt="Tildr" width="180"/>
</p>

<h2 align="center">Declarative CLI for managing your Linux HOME directory.</h2>

## Installation (Fedora / RPM)

### Via Repository (Recommended)

```sh
# Import GPG key
sudo rpm --import https://orbitbits.github.io/tildr-rpm/RPM-GPG-KEY-tildr

# Add repository
sudo dnf config-manager addrepo --from-repofile=https://orbitbits.github.io/tildr-rpm/tildr.repo

# Install
sudo dnf install tildr
```

### Via Direct RPM Download

Download the `.rpm` file from [releases](https://github.com/orbitbits/tildr/releases) and install:

```sh
sudo dnf install ./tildr-*.rpm
```

---

## Maintainer workflow

### Prerequisites

```sh
sudo dnf install rpm-build createrepo-c curl git gnupg
```

### Build package

```sh
make build
```

### Install package local (test)

```sh
make install
```

> Note: Always test with `make install` before publishing.

### Build source RPM

```sh
make srpm
```

### Lint spec file

```sh
make lint
```

### Show current version

```sh
make version
```

### Generate local repo (test)

```sh
make publish-repo
```

This creates a local repo structure in `repo/` for testing.

### Clean all build files

```sh
make clean
```

---

## Publishing a release

Releases are **fully automatic**. Every Saturday at 00:00 UTC a cron job
checks [orbitbits/tildr](https://github.com/orbitbits/tildr) for new
releases. When a new tag is detected, the workflow automatically:

1. Builds RPMs for Fedora 42, 43, 44
2. Creates a GitHub Release with the RPMs attached
3. Publishes the RPM repository to GitHub Pages

No manual intervention needed — just release on `tildr` and this repo
picks it up within a week.

### Manual trigger

You can also trigger the workflow manually from the Actions tab
(`workflow_dispatch`) to build immediately without waiting for the cron.

### Publishing to official Fedora/EPEL

The flow above only covers **this repo's own releases** (distributed via
your own GitHub Pages repo). Submitting to the official Fedora/EPEL
repositories goes through Fedora's own review (Bugzilla) and update process
(Bodhi), and is intentionally **not** automated here — that step stays
manual.

---

## GitHub Secrets (for maintainers)

| Secret | Description |
|--------|-------------|
| `GPG_PRIVATE_KEY` | GPG private key (ASCII-armored) |
| `GPG_PASSPHRASE` | GPG key passphrase |

Export your key:
```sh
gpg --export -a 'Your Key Name'
```

---

## Git helpers

```sh
make push          # push to all remotes
make push-lease    # push --force-with-lease to all remotes
```

---

## Templates in this repository

* `tildr.spec` — RPM build recipe (Fedora / RHEL / CentOS)
* `tools/main.sh` — Build script with download, setup, and packaging logic
* `tools/publish-repo.sh` — Local repo generation script
* `rpmlint.toml` — rpmlint configuration for spec validation
* `.github/workflows/build-rpm.yml` — CI build workflow (push/PR)
* `.github/workflows/release-from-tildr.yml` — Auto-release from tildr (weekly cron)
* `.github/workflows/publish-repo.yml` — RPM repo publication to GitHub Pages
* `repo/tildr.repo` — DNF repository configuration file

---

## Notes

* This repository does **not** contain the source code.
* The spec file downloads the source directly from GitHub releases.
* Always test with `make install` before publishing.

---

## Supported distros

* Fedora 42, 43, 44
* CentOS Stream
* Rocky Linux
* AlmaLinux
* Any RPM-based distro with `rpm-build`

---

## Official page

https://orbitbits.com/tildr/

---

&copy; [OrbitBits](https://orbitbits.com) - All rights reserved.
