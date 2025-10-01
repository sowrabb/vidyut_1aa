#!/bin/bash
# Analyze Dart/Flutter code for errors and warnings

set -e

echo "🔍 Running Flutter analyzer..."
flutter analyze --no-fatal-infos

echo "✅ Analysis complete!"




