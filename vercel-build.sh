#!/bin/bash
set -e

# Bitaqwa web build for Vercel — PWA Phase 2B.
#
# Flutter is pinned to the exact version used locally (3.44.7) so the
# deployed build can never drift from what was tested. After the web build,
# tool/inject_build_id.dart stamps the service worker with the build ID.

FLUTTER_VERSION=3.44.7

echo "=== Installing Flutter SDK (pinned to $FLUTTER_VERSION) ==="

git clone https://github.com/flutter/flutter.git \
  --depth 1 \
  -b "$FLUTTER_VERSION" \
  /tmp/flutter

export PATH="/tmp/flutter/bin:$PATH"

echo "=== Checking Flutter ==="
FLUTTER_VERSION_OUTPUT="$(flutter --version)"
echo "$FLUTTER_VERSION_OUTPUT"
echo "$FLUTTER_VERSION_OUTPUT" | grep -q "Flutter $FLUTTER_VERSION" || {
  echo "FATAL: Flutter SDK is not $FLUTTER_VERSION; refusing to build."
  exit 1
}

echo "=== Installing dependencies ==="
flutter pub get

echo "=== Building Bitaqwa Web ==="
flutter build web --release

echo "=== Injecting PWA build ID into sw.js ==="
dart tool/inject_build_id.dart build/web/sw.js

echo "=== Build completed ==="
