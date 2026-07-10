#!/usr/bin/env bash
# Maintainer: William Canin <hello.williamcanin@gmail.com>
#
# Local script to test RPM repository generation.
# This simulates what the GitHub Actions workflow does.

# --- VARIABLES ---
BUILD_DIR="rpmbuild"
REPO_DIR="repo"
FEDORA_VERSIONS="39 40 41"

# --- UI ---
info()    { printf "\033[0;36m-> %s\033[0m\n" "$1"; }
error()   { printf "\033[0;31mx %s\033[0m\n" "$1"; }
success() { printf "\033[0;32m* %s\033[0m\n" "$1"; }

# --- Checks ---
[ "$(uname -s)" != "Linux" ] && { error "Linux only"; exit 1; }
command -v createrepo_c >/dev/null || { error "createrepo_c not found. Install: dnf install createrepo_c"; exit 1; }
command -v gpg >/dev/null || { error "gpg not found"; exit 1; }

if [ "$(id -u)" -eq 0 ]; then error "Do not run as root or sudo"; exit 1; fi

# --- Find RPM ---
find_rpm() {
  local rpm_file
  rpm_file=$(find "${BUILD_DIR}/RPMS" -name "*.rpm" -type f 2>/dev/null | head -1)
  if [ -z "$rpm_file" ]; then
    error "No RPM found in ${BUILD_DIR}/RPMS. Run 'make build' first."
    exit 1
  fi
  echo "$rpm_file"
}

# --- Setup repo structure ---
setup_repo() {
  info "Setting up repo structure..."
  for ver in $FEDORA_VERSIONS; do
    mkdir -p "${REPO_DIR}/fedora/${ver}/x86_64"
  done
}

# --- Copy RPMs ---
copy_rpms() {
  local rpm_file="$1"
  info "Copying RPM to repo..."
  for ver in $FEDORA_VERSIONS; do
    cp "$rpm_file" "${REPO_DIR}/fedora/${ver}/x86_64/"
  done
}

# --- Sign RPMs ---
sign_rpms() {
  info "Signing RPMs..."
  for ver in $FEDORA_VERSIONS; do
    for rpm in ${REPO_DIR}/fedora/${ver}/x86_64/*.rpm; do
      [ -f "$rpm" ] || continue
      rpm --addsign "$rpm" 2>/dev/null || {
        error "Failed to sign $rpm. Check your GPG configuration."
        return 1
      }
    done
  done
}

# --- Generate metadata ---
generate_metadata() {
  info "Generating repository metadata..."
  for ver in $FEDORA_VERSIONS; do
    local dir="${REPO_DIR}/fedora/${ver}/x86_64"
    if [ -d "$dir" ] && ls "$dir"/*.rpm &>/dev/null; then
      createrepo_c "$dir/"
    fi
  done
}

# --- Sign metadata ---
sign_metadata() {
  info "Signing repomd.xml..."
  for ver in $FEDORA_VERSIONS; do
    local repomd="${REPO_DIR}/fedora/${ver}/x86_64/repodata/repomd.xml"
    if [ -f "$repomd" ]; then
      gpg --detach-sign --armor "$repomd"
    fi
  done
}

# --- Test server ---
test_server() {
  info "Starting test server on http://localhost:8080"
  info "Press Ctrl+C to stop"
  echo
  cd "${REPO_DIR}" || exit
  python3 -m http.server 8080
}

# --- Menu ---
case "${1:-}" in
  setup)
    setup_repo
    success "Repo structure created"
    ;;
  copy)
    RPM=$(find_rpm)
    setup_repo
    copy_rpms "$RPM"
    success "RPMs copied"
    ;;
  sign)
    sign_rpms
    success "RPMs signed"
    ;;
  metadata)
    generate_metadata
    sign_metadata
    success "Metadata generated and signed"
    ;;
  generate)
    RPM=$(find_rpm)
    setup_repo
    copy_rpms "$RPM"
    generate_metadata
    sign_metadata
    success "Full repo generated"
    ;;
  serve)
    test_server
    ;;
  *)
    error "Unknown command: $1"
    printf "Usage: %s [setup|copy|sign|metadata|generate|serve]\n" "$0"
    echo
    echo "  setup     - Create repo directory structure"
    echo "  copy      - Copy built RPM to repo"
    echo "  sign      - Sign RPMs with GPG"
    echo "  metadata  - Generate and sign repo metadata"
    echo "  generate  - Full pipeline (copy + metadata)"
    echo "  serve     - Start local test server on port 8080"
    exit 1
    ;;
esac
