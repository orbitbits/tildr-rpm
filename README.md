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

Releases here are **automatic**, triggered by the main [`tildr`](https://github.com/orbitbits/tildr)
repository whenever it cuts a new version. No version needs to be edited by
hand in this repo — `PKGVER` is injected at build time.

Flow, end to end:

1. `tildr`'s own release workflow finishes and fires a `repository_dispatch`
   (`tildr-release`) to this repo, with the new tag as payload.
2. `release-from-tildr.yml` picks it up, and for each of Fedora 42/43/44:
   - downloads that exact release's binary and man pages
     from `tildr`'s GitHub release — **never** from the `main` branch
   - builds the RPM (`make build`) and lints it (`make lint`)
3. Once all three builds succeed, a GitHub Release is created **here**,
   with tag matching Tildr's (e.g. `v0.1.0`), with all three `.rpm` files attached.
4. `publish-repo.yml` picks that release up automatically:
   - downloads the RPMs
   - signs them with GPG
   - generates repository metadata
   - deploys to GitHub Pages

### Manual / re-run

If you need to (re)build a specific version without waiting for a new Tildr
release, trigger `release-from-tildr.yml` manually from the Actions tab
(`workflow_dispatch`), passing the tag (e.g. `v0.1.0`).

### Dependency on the `tildr` repo

This only works once `tildr`'s own release workflow:

- publishes a Linux binary per release (e.g.
  `tildr-<version>-linux-x86_64`)
- sends a `repository_dispatch` (`event_type: tildr-release`,
  `client_payload: {"tag": "vX.Y.Z"}`) to this repo (and to `tildr-deb`)
  after publishing that release

Until both exist upstream, `release-from-tildr.yml` can still be triggered
manually from the Actions tab (`workflow_dispatch`), passing the tag
(e.g. `v0.1.0`).

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
* `.github/workflows/build-rpm.yml` — GitHub Actions CI/CD workflow
* `.github/workflows/publish-repo.yml` — RPM repo publication workflow
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
