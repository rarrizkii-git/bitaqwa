
#!/bin/bash
set -e

echo "=== Installing Flutter SDK ==="

git clone https://github.com/flutter/flutter.git \
  --depth 1 \
  -b stable \
  /tmp/flutter

export PATH="/tmp/flutter/bin:$PATH"

echo "=== Checking Flutter ==="
flutter --version

echo "=== Installing dependencies ==="
flutter pub get

echo "=== Building Bitaqwa Web ==="
flutter build web --release

echo "=== Build completed ==="
