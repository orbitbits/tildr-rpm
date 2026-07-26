<!-- markdownlint-disable MD033 -->
<!-- markdownlint-disable MD041 -->

<p align="center">
  <img style="border-radius: 5px;" src="https://raw.githubusercontent.com/orbitbits/tildr/refs/heads/main/.github/brand/logo-text/compact/tildr-variation-3.svg" alt="Tildr" width="180"/>
</p>

<h2 align="center">Declarative CLI for managing your Linux HOME directory.</h2>

## Installation (RPM-based Linux)

### Via Repository (Recommended)

```sh
# Import GPG key
sudo rpm --import https://packages.orbitbits.com/keys/orbitbits.gpg

# Add repository
sudo dnf config-manager addrepo --from-repofile=https://packages.orbitbits.com/rpm/orbitbits.repo

# Install
sudo dnf install tildr
```

### Via Direct RPM Download

Download the `.rpm` file from [releases](https://github.com/orbitbits/tildr-rpm/releases) and install:

```sh
sudo dnf install ./tildr-*.rpm
```

## Supported distros

* Fedora
* CentOS Stream
* Rocky Linux
* AlmaLinux
* Any RPM-based distro with `dnf`

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Official page

[https://orbitbits.com/tildr](https://orbitbits.com/tildr)

---

&copy; [OrbitBits](https://orbitbits.com) - All rights reserved.
