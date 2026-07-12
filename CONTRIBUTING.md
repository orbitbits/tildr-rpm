<!-- markdownlint-disable MD033 -->
<!-- markdownlint-disable MD041 -->

# Contributing to tildr-rpm

## Prerequisites

```sh
# Fedora
sudo dnf install -y rpm-build rpmlint createrepo-c curl git make gnupg

# Verify
rpmbuild --version
make --version
```

## Project structure

```
tildr-rpm/
├── tildr.spec                  # RPM spec file
├── Makefile                    # Build commands
├── tools/
│   ├── main.sh                 # Build script (download, package, lint)
│   └── publish-repo.sh         # Local repo generation for testing
├── repo/
│   └── tildr.repo              # DNF repo config template
├── rpmlint.toml                # rpmlint config
└── .github/workflows/
    ├── build-rpm.yml           # CI build (push/PR)
    ├── release-from-tildr.yml  # Auto-release (weekly cron)
    └── publish-repo.yml        # Manual publish trigger
```

## Local development workflow

### 1. Build the RPM

```sh
make build
```

This downloads the binary and man pages from the latest tildr release on
GitHub, then builds the RPM. The output is in `rpmbuild/RPMS/`.

### 2. Install locally (test)

```sh
make install
```

Builds and installs the RPM via `dnf`. Use this to verify the package
works before publishing.

### 3. Lint the spec file

```sh
make lint
```

Validates `tildr.spec` with rpmlint.

### 4. Build source RPM

```sh
make srpm
```

Generates a source RPM in `rpmbuild/SRPMS/`.

### 5. Generate local repo (test)

```sh
make publish-repo
```

Creates a local RPM repository in `repo/` for testing with DNF.

#### Test the local repo

```sh
# Start a local server
make serve   # or: bash tools/publish-repo.sh serve

# In another terminal, add the repo and install
sudo dnf config-manager addrepo --from-repofile=http://localhost:8080/fedora/42/repodata/tildr.repo
sudo dnf install tildr
```

### 6. Clean

```sh
make clean
```

## Publishing an RPM manually

If you need to publish a release **without waiting for the Saturday cron**:

### Option A: Trigger the workflow from GitHub UI

1. Go to **Actions** → **Release from Tildr**
2. Click **Run workflow**
3. (workflow_dispatch does not require a tag input — it auto-detects the
   latest tildr release)

### Option B: Create a release directly

If the RPMs are already built locally:

```sh
# 1. Build
make build

# 2. Rename with dist tag (e.g. for Fedora 42)
mv rpmbuild/RPMS/x86_64/tildr-*.rpm rpmbuild/RPMS/x86_64/tildr-0.1.0-1.fc42.x86_64.rpm

# 3. Create GitHub release and upload RPMs
gh release create v0.1.0 \
  --title "Release v0.1.0" \
  --generate-notes \
  rpmbuild/RPMS/x86_64/*.rpm
```

The `publish-repo.yml` workflow will pick up the new release
automatically and deploy to GitHub Pages.

## Commit conventions

This project follows [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new feature
fix: correct something
docs: update documentation
chore: maintenance tasks
refactor: restructure code
```

## Workflows

| Workflow | Trigger | What it does |
|----------|---------|-------------|
| `build-rpm.yml` | push/PR to main | Builds RPMs for Fedora 42/43/44, runs lint |
| `release-from-tildr.yml` | cron (Saturday) + manual | Checks for new tildr release, builds + publishes if new |
| `publish-repo.yml` | release published | Downloads RPMs, signs, generates metadata, deploys to Pages |

## GitHub Secrets

| Secret | Description |
|--------|-------------|
| `GPG_PRIVATE_KEY` | GPG private key (ASCII-armored) for signing RPMs |
| `GPG_PASSPHRASE` | Passphrase for the GPG key |

Export your key (used only for local/manual verification — CI now exports
by fingerprint automatically, see `publish-repo.yml`):

```sh
gpg --export -a "$(gpg --list-secret-keys --with-colons | awk -F: '/^fpr:/{print $10; exit}')" > tildr-rpm-pub.gpg
```

## RPM repository structure (after publish)

```
https://orbitbits.com/tildr-rpm/
├── tildr-rpm-pub.gpg
├── fedora/
│   ├── 42/x86_64/
│   │   ├── tildr-0.1.0-1.fc42.x86_64.rpm
│   │   ├── tildr-0.1.0-1.fc42.x86_64.rpm.asc
│   │   └── repodata/
│   ├── 43/x86_64/
│   └── 44/x86_64/
```

## Supported Fedora versions

* Fedora 42, 43, 44

---

&copy; [OrbitBits](https://orbitbits.com) - All rights reserved.
