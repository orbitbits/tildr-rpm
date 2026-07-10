<!-- markdownlint-disable MD033 -->
<!-- markdownlint-disable MD041 -->

<p align="center">
  <img style="border-radius: 5px;" src="https://raw.githubusercontent.com/orbitbits/tildr/refs/heads/main/.github/brand/logo-text/compact/tildr-variation-3.svg" alt="Tildr" width="180"/>
</p>

<h2 align="center">Declarative CLI for managing your Linux HOME directory.</h2>

## Maintainer workflow (Fedora / RPM)

### Prerequisites

```sh
sudo dnf install rpm-build curl git
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

### Clean all build files

```sh
make clean
```

---

## Updating package when a new GitHub tag is released

Example: new version `0.2.0`

1. Update version in `tools/main.sh`:

```sh
# edit tools/main.sh
PKGVER=0.2.0
```

2. Update version in `tildr.spec`:

```sh
# edit tildr.spec
Version:        0.2.0
```

3. Rebuild:

```sh
make build
```

4. Commit and push:

```sh
git add . && git commit -m "bump to 0.2.0" && git push
```

Done.

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

---

## Notes

* This repository does **not** contain the source code.
* The spec file downloads the source directly from GitHub releases.
* Always test with `make install` before publishing.

---

## Supported distros

* Fedora
* CentOS Stream
* Rocky Linux
* AlmaLinux
* Any RPM-based distro with `rpm-build`

---

## Official page

https://orbitbits.com/tildr/

---

&copy; [OrbitBits](https://orbitbits.com) - All rights reserved.
