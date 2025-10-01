#!/bin/bash
# Run Flutter tests with coverage

set -e

echo "🧪 Running Flutter tests..."
flutter test --coverage

echo "📊 Generating coverage report..."
if command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html
    echo "📈 Coverage report generated at coverage/html/index.html"
else
    echo "⚠️  genhtml not installed. Install lcov to generate HTML coverage reports."
fi

echo "✅ Tests complete!"




