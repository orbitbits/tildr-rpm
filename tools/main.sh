#!/usr/bin/env bash
# Maintainer: William Canin <hello.williamcanin@gmail.com>

# --- VARIABLES ---
PKGVER=0.1.0
PKGNAME="tildr"
REPO="orbitbits/tildr"
BRANCH="main"
BUILD_DIR="rpmbuild"

# --- UI ---
info()    { printf "\033[0;36m-> %s\033[0m\n" "$1"; }
error()   { printf "\033[0;31mx %s\033[0m\n" "$1"; }
success() { printf "\033[0;32m* %s\033[0m\n" "$1"; }

# --- Checks ---
[ "$(uname -s)" != "Linux" ] && { error "Linux only"; exit 1; }
[ "$(uname -m)" != "x86_64" ] && { error "Only x86_64 supported"; exit 1; }
command -v git >/dev/null || { error "git is required"; exit 1; }
command -v rpmbuild >/dev/null || { error "rpmbuild not found. Install: dnf install rpm-build"; exit 1; }

if [ "$(id -u)" -eq 0 ]; then error "Do not run as root or sudo"; exit 1; fi

# --- URLs ---
_github_base="https://github.com/${REPO}"
_raw_base="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
_release_base="${_github_base}/releases/download/v${PKGVER}"
_man_base="${_raw_base}/docs/man/dist"

# --- Create rpmbuild structure ---
setup_rpm_dirs() {
  mkdir -p "${BUILD_DIR}"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
}

# --- Download sources ---
download_sources() {
  local sources_dir="${BUILD_DIR}/SOURCES"

  info "Downloading binary..."
  curl -sL "${_release_base}/tildr-${PKGVER}-linux-x86_64" \
    -o "${sources_dir}/tildr-${PKGVER}-linux-x86_64"

  info "Downloading man pages..."
  curl -sL "${_man_base}/tildr.1" \
    -o "${sources_dir}/tildr.1"
  curl -sL "${_man_base}/tildr-config.1" \
    -o "${sources_dir}/tildr-config.1"
  curl -sL "${_man_base}/tildr-commands.1" \
    -o "${sources_dir}/tildr-commands.1"
  curl -sL "${_man_base}/tildr-security.1" \
    -o "${sources_dir}/tildr-security.1"
  curl -sL "${_man_base}/tildr-plugins.1" \
    -o "${sources_dir}/tildr-plugins.1"

  info "Downloading plugins..."
  curl -sL "${_raw_base}/tools/plugins/nautilus/tildr.py" \
    -o "${sources_dir}/tildr.py"
  curl -sL "${_raw_base}/tools/plugins/dolphin/tildr.desktop" \
    -o "${sources_dir}/tildr.desktop"

  info "Downloading LICENSE..."
  curl -sL "${_raw_base}/LICENSE" \
    -o "${sources_dir}/LICENSE"
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
  install)
    setup_rpm_dirs
    download_sources
    copy_spec
    update_spec_version
    install_rpm
    ;;
  clean)
    clean_build
    ;;
  *)
    error "Unknown command: $1"
    printf "Usage: %s [build|install|clean]\n" "$0"
    exit 1
    ;;
esac
