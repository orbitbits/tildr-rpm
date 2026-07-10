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
warn()    { printf "\033[0;33m! %s\033[0m\n" "$1"; }

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
download_sources() {
  local sources_dir="${BUILD_DIR}/SOURCES"

  download "${_release_base}/tildr-${PKGVER}-linux-x86_64" \
    "${sources_dir}/tildr-${PKGVER}-linux-x86_64" "binary" || return 1

  download "${_man_base}/tildr.1" \
    "${sources_dir}/tildr.1" "tildr.1" || return 1
  download "${_man_base}/tildr-config.1" \
    "${sources_dir}/tildr-config.1" "tildr-config.1" || return 1
  download "${_man_base}/tildr-commands.1" \
    "${sources_dir}/tildr-commands.1" "tildr-commands.1" || return 1
  download "${_man_base}/tildr-security.1" \
    "${sources_dir}/tildr-security.1" "tildr-security.1" || return 1
  download "${_man_base}/tildr-plugins.1" \
    "${sources_dir}/tildr-plugins.1" "tildr-plugins.1" || return 1

  download "${_raw_base}/tools/plugins/nautilus/tildr.py" \
    "${sources_dir}/tildr.py" "Nautilus plugin" || return 1
  download "${_raw_base}/tools/plugins/dolphin/tildr.desktop" \
    "${sources_dir}/tildr.desktop" "Dolphin plugin" || return 1

  download "${_raw_base}/LICENSE" \
    "${sources_dir}/LICENSE" "LICENSE" || return 1
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
