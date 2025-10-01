#!/bin/bash
# Build Flutter web app for production

set -e

echo "🌐 Building Flutter web app..."
flutter build web --release

echo "📦 Build artifacts at build/web/"
echo "✅ Web build complete!"




