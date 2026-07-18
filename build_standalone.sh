#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/fingerprint_backend"
FRONTEND_DIR="$SCRIPT_DIR/fingerprint_frontend"
BUILD_DIR="$SCRIPT_DIR/build"
VENV_DIR="$BACKEND_DIR/venv"
POSTGRES_VERSION="16.4"
POSTGRES_URL="https://get.enterprisedb.com/postgresql/postgresql-${POSTGRES_VERSION}-1-linux-x64-binaries.tar.gz"

log() { echo "[build] $*"; }

cleanup() {
  log "Cleaning up..."
  rm -rf "$BUILD_DIR"
}

# Parse arguments
TARGET="${1:-linux}"
CLEAN="${2:-}"

if [ "$CLEAN" = "--clean" ]; then
  cleanup
fi

mkdir -p "$BUILD_DIR"

# ── Step 1: Setup Python environment ──
log "Setting up Python environment..."
if [ ! -d "$VENV_DIR" ]; then
  python3 -m venv "$VENV_DIR"
fi
source "$VENV_DIR/bin/activate"
pip install -q --upgrade pip
pip install -q -r "$BACKEND_DIR/requirements.txt"
pip install -q pyinstaller

# ── Step 2: Build backend with PyInstaller ──
log "Building backend with PyInstaller..."
cd "$BACKEND_DIR"
pyinstaller --clean \
  --distpath "$BUILD_DIR/backend_dist" \
  --workpath "$BUILD_DIR/backend_build" \
  backend.spec
cd "$SCRIPT_DIR"

BACKEND_EXE="$BUILD_DIR/backend_dist/backend_server"

# ── Step 3: Download PostgreSQL portable ──
POSTGRES_DIR="$BUILD_DIR/postgres"
if [ ! -d "$POSTGRES_DIR/bin" ]; then
  log "Downloading PostgreSQL ${POSTGRES_VERSION} portable..."
  POSTGRES_TAR="$BUILD_DIR/postgresql.tar.gz"
  if [ ! -f "$POSTGRES_TAR" ]; then
    wget -q "$POSTGRES_URL" -O "$POSTGRES_TAR" || {
      log "Warning: Could not download PostgreSQL. App will require system PostgreSQL."
      mkdir -p "$POSTGRES_DIR"
    }
  fi
  if [ -f "$POSTGRES_TAR" ]; then
    log "Extracting PostgreSQL..."
    tar xzf "$POSTGRES_TAR" -C "$BUILD_DIR"
    # The extracted dir is usually named pgsql/ or postgresql-*/
    if [ -d "$BUILD_DIR/pgsql" ]; then
      mv "$BUILD_DIR/pgsql" "$POSTGRES_DIR"
    else
      EXTRACTED_DIR=$(find "$BUILD_DIR" -maxdepth 1 -type d -name "postgresql*" -o -name "pgsql" | head -1)
      if [ -n "$EXTRACTED_DIR" ] && [ "$EXTRACTED_DIR" != "$POSTGRES_DIR" ]; then
        mv "$EXTRACTED_DIR" "$POSTGRES_DIR"
      fi
    fi
    rm -f "$POSTGRES_TAR"
  fi
fi

# ── Step 4: Bundle everything ──
log "Bundling files..."
FLUTTER_BUNDLE_DIR="$FRONTEND_DIR/build/linux/x64/release/bundle"

if [ "$TARGET" = "linux" ]; then
  log "Building Flutter Linux app..."
  cd "$FRONTEND_DIR"
  flutter build linux --release
  
  BUNDLE_BACKEND_DIR="$FLUTTER_BUNDLE_DIR/backend"
  mkdir -p "$BUNDLE_BACKEND_DIR"
  
  cp "$BACKEND_EXE" "$BUNDLE_BACKEND_DIR/"
  cp -r "$BACKEND_DIR/migrations" "$BUNDLE_BACKEND_DIR/"
  
  # Copy PostgreSQL portable
  if [ -d "$POSTGRES_DIR/bin" ]; then
    BUNDLE_POSTGRES_DIR="$FLUTTER_BUNDLE_DIR/postgres"
    mkdir -p "$BUNDLE_POSTGRES_DIR"
    cp -r "$POSTGRES_DIR"/* "$BUNDLE_POSTGRES_DIR/"
  fi
  
  log "Build complete: $FLUTTER_BUNDLE_DIR"
  
elif [ "$TARGET" = "windows" ]; then
  log "Building Flutter Windows app..."
  cd "$FRONTEND_DIR"
  flutter build windows --release
  
  FLUTTER_BUNDLE_DIR="$FRONTEND_DIR/build/windows/x64/runner/Release"
  BUNDLE_BACKEND_DIR="$FLUTTER_BUNDLE_DIR/backend"
  mkdir -p "$BUNDLE_BACKEND_DIR"
  
  cp "$BACKEND_EXE" "$BUNDLE_BACKEND_DIR/"
  cp -r "$BACKEND_DIR/migrations" "$BUNDLE_BACKEND_DIR/"
  
  if [ -d "$POSTGRES_DIR/bin" ]; then
    BUNDLE_POSTGRES_DIR="$FLUTTER_BUNDLE_DIR/postgres"
    mkdir -p "$BUNDLE_POSTGRES_DIR"
    cp -r "$POSTGRES_DIR"/* "$BUNDLE_POSTGRES_DIR/"
  fi
  
  log "Build complete: $FLUTTER_BUNDLE_DIR"
fi

log "Done!"
