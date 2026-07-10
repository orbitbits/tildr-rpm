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

1. Update version in `tools/main.sh` and `tildr.spec`
2. Build and test: `make build && make install`
3. Commit and create a GitHub release with the RPM attached
4. The `publish-repo.yml` workflow automatically:
   - Downloads the RPM from the release
   - Signs it with GPG
   - Generates repository metadata
   - Deploys to GitHub Pages

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

* Fedora 39, 40, 41
* CentOS Stream
* Rocky Linux
* AlmaLinux
* Any RPM-based distro with `rpm-build`

---

## Official page

https://orbitbits.com/tildr/

---

&copy; [OrbitBits](https://orbitbits.com) - All rights reserved.
