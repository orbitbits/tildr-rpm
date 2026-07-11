#!/usr/bin/env bash
# Maintainer: William Canin <hello.williamcanin@gmail.com>
set -euo pipefail
# --- VARIABLES ---
# PKGVER can be injected by CI (e.g. from a repository_dispatch payload).
# Falls back to the version pinned in tildr.spec for local/manual builds.
PKGVER="${PKGVER:-$(grep '^Version:' tildr.spec | awk '{print $2}')}"
PKGNAME="tildr"
REPO="orbitbits/tildr"
TAG="v${PKGVER}"
BUILD_DIR="rpmbuild"

# --- UI ---
info()    { printf "\033[0;36m-> %s\033[0m\n" "$1"; }
error()   { printf "\033[0;31mx %s\033[0m\n" "$1"; }
success() { printf "\033[0;32m* %s\033[0m\n" "$1"; }
warn()    { printf "\033[0;33m! %s\033[0m\n" "$1"; }

# --- Checks ---
[ "$(uname -s)" != "Linux" ] && { error "Linux only"; exit 1; }
[ "$(uname -m)" != "x86_64" ] && { error "Only x86_64 supported"; exit 1; }
command -v git >/dev/null || { error "git is required"; exit 1; }
command -v rpmbuild >/dev/null || { error "rpmbuild not found. Install: dnf install rpm-build"; exit 1; }

if [ "$(id -u)" -eq 0 ]; then error "Do not run as root or sudo"; exit 1; fi

# --- URLs ---
# NOTE: sources are pinned to the release tag (${TAG}), never to "main".
# This guarantees the package always matches exactly what was released,
# even if the main branch has moved on since then.
_github_base="https://github.com/${REPO}"
_release_base="${_github_base}/releases/download/${TAG}"
_tarball_url="https://api.github.com/repos/${REPO}/tarball/${TAG}"
_binary_name="${PKGNAME}-${PKGVER}-linux-x86_64"

# --- Create rpmbuild structure ---
setup_rpm_dirs() {
  mkdir -p "${BUILD_DIR}"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
}

# --- Download with error handling ---
download() {
  local url="$1"
  local dest="$2"
  local label="$3"

  info "Downloading ${label}..."
  if ! curl -sLf "${url}" -o "${dest}"; then
    error "Failed to download ${label}"
    return 1
  fi
}

# --- Download sources ---
# Binary comes from the GitHub release; man pages, plugins and LICENSE
# are extracted from the auto-generated source tarball for the tag.
download_sources() {
  local sources_dir="${BUILD_DIR}/SOURCES"

  download "${_release_base}/${_binary_name}" \
    "${sources_dir}/${_binary_name}" "release binary (${_binary_name})" || {
    error "Could not find ${_binary_name} on the ${TAG} release."
    error "Make sure the Tildr release workflow publishes a linux binary"
    error "for this version before retrying."
    return 1
  }

  local tmp_tarball
  tmp_tarball=$(mktemp -d)

  download "${_tarball_url}" \
    "${tmp_tarball}/source.tar.gz" "source tarball (${TAG})" || {
    error "Could not download source tarball for ${TAG}."
    rm -rf "${tmp_tarball}"
    return 1
  }

  info "Extracting source tarball..."
  tar -xzf "${tmp_tarball}/source.tar.gz" -C "${tmp_tarball}" || {
    error "Failed to extract source tarball"
    rm -rf "${tmp_tarball}"
    return 1
  }

  local src_root
  src_root=$(find "${tmp_tarball}" -mindepth 1 -maxdepth 1 -type d -name "*-${REPO##*/}-*" | head -1)
  if [ -z "${src_root}" ]; then
    error "Could not locate extracted source directory inside tarball"
    rm -rf "${tmp_tarball}"
    return 1
  fi

  local man_files=(
    "tildr.1"
    "tildr-config.1"
    "tildr-commands.1"
    "tildr-security.1"
    "tildr-plugins.1"
  )
  for mf in "${man_files[@]}"; do
    if [ -f "${src_root}/docs/man/dist/${mf}" ]; then
      cp "${src_root}/docs/man/dist/${mf}" "${sources_dir}/${mf}"
    else
      error "Man page ${mf} not found in source tarball"
      rm -rf "${tmp_tarball}"
      return 1
    fi
  done

  if [ -f "${src_root}/tools/plugins/nautilus/tildr.py" ]; then
    cp "${src_root}/tools/plugins/nautilus/tildr.py" "${sources_dir}/tildr.py"
  else
    error "Nautilus plugin not found in source tarball"
    rm -rf "${tmp_tarball}"
    return 1
  fi

  if [ -f "${src_root}/tools/plugins/dolphin/tildr.desktop" ]; then
    cp "${src_root}/tools/plugins/dolphin/tildr.desktop" "${sources_dir}/tildr.desktop"
  else
    error "Dolphin plugin not found in source tarball"
    rm -rf "${tmp_tarball}"
    return 1
  fi

  if [ -f "${src_root}/LICENSE" ]; then
    cp "${src_root}/LICENSE" "${sources_dir}/LICENSE"
  else
    error "LICENSE not found in source tarball"
    rm -rf "${tmp_tarball}"
    return 1
  fi

  rm -rf "${tmp_tarball}"
}

# --- Copy spec file ---
copy_spec() {
  cp -f tildr.spec "${BUILD_DIR}/SPECS/tildr.spec"
}

# --- Update version in spec ---
update_spec_version() {
  sed -i "s|^Version:.*|Version:        ${PKGVER}|" "${BUILD_DIR}/SPECS/tildr.spec"
}

# --- Build RPM ---
build_rpm() {
  info "Building RPM package..."
  rpmbuild -bb "${BUILD_DIR}/SPECS/tildr.spec" \
    --define "_topdir $(pwd)/${BUILD_DIR}"
  expectation $? success "Success! RPM build complete"
}

# --- Build SRPM ---
build_srpm() {
  info "Building source RPM package..."
  rpmbuild -bs "${BUILD_DIR}/SPECS/tildr.spec" \
    --define "_topdir $(pwd)/${BUILD_DIR}"
  expectation $? success "Success! SRPM build complete"
}

# --- Install RPM ---
install_rpm() {
  info "Building and installing RPM package..."
  rpmbuild -bb "${BUILD_DIR}/SPECS/tildr.spec" \
    --define "_topdir $(pwd)/${BUILD_DIR}"
  expectation $? success "Build complete. Installing..."

  local rpm_file
  rpm_file=$(find "${BUILD_DIR}/RPMS" -name "*.rpm" -type f | head -1)
  if [ -n "$rpm_file" ]; then
    info "Installing: ${rpm_file}"
    sudo dnf install -y "${rpm_file}"
    expectation $? success "Success! Install complete"
  else
    error "RPM file not found"
    exit 1
  fi
}

# --- Lint spec ---
lint_spec() {
  if ! command -v rpmlint >/dev/null 2>&1; then
    warn "rpmlint not found. Install: dnf install rpmlint"
    return 1
  fi

  info "Linting spec file..."
  rpmlint -c rpmlint.toml "${BUILD_DIR}/SPECS/tildr.spec"
  expectation $? success "Lint passed"
}

# --- Clean ---
clean_build() {
  info "Cleaning build files..."
  rm -rf "${BUILD_DIR}"
  expectation $? success "Clean complete"
}

# --- Expectation helper ---
expectation() {
  local status=$1
  local cmd=$2
  local msg=$3

  if [ "$status" -eq 0 ]; then
    "$cmd" "$msg"
  fi
}

# --- Menu ---
case "${1:-}" in
  build)
    setup_rpm_dirs
    download_sources
    copy_spec
    update_spec_version
    build_rpm
    ;;
  srpm)
    setup_rpm_dirs
    download_sources
    copy_spec
    update_spec_version
    build_srpm
    ;;
  install)
    setup_rpm_dirs
    download_sources
    copy_spec
    update_spec_version
    install_rpm
    ;;
  lint)
    setup_rpm_dirs
    copy_spec
    lint_spec
    ;;
  clean)
    clean_build
    ;;
  *)
    error "Unknown command: $1"
    printf "Usage: %s [build|srpm|install|lint|clean]\n" "$0"
    exit 1
    ;;
esac
