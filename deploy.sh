#!/bin/bash

# Deploy Flutter Web App to GitHub Pages
# This script builds the Flutter web app and prepares it for GitHub Pages deployment

echo "🚀 Starting deployment process..."

# Build the Flutter web app
echo "📦 Building Flutter web app..."
flutter build web --release

if [ $? -eq 0 ]; then
    echo "✅ Flutter web build successful!"
else
    echo "❌ Flutter web build failed!"
    exit 1
fi

# Create a simple index.html redirect for GitHub Pages
echo "📝 Creating GitHub Pages configuration..."

# Create .nojekyll file to prevent Jekyll processing
touch build/web/.nojekyll

# Create a simple README for the deployment
cat > build/web/README.md << EOF
# Vidyut Electrical Marketplace

This is the web deployment of the Vidyut electrical marketplace Flutter application.

## Live Demo

Visit: [https://yourusername.github.io/vidyut/](https://yourusername.github.io/vidyut/)

## Features

- Responsive design for desktop, tablet, and mobile
- Product catalog with categories
- Search functionality
- Seller profiles and product listings
- Admin dashboard
- Real-time messaging (coming soon)
- User authentication (coming soon)

## Technology Stack

- Flutter Web
- Material Design 3
- Responsive UI components
- Firebase (backend integration in progress)

## Development

This app is built with Flutter and deployed to GitHub Pages.

EOF

echo "✅ Deployment files created!"
echo ""
echo "📋 Next steps:"
echo "1. Initialize git repository: git init"
echo "2. Add remote: git remote add origin https://github.com/yourusername/vidyut.git"
echo "3. Add files: git add ."
echo "4. Commit: git commit -m 'Deploy Flutter web app'"
echo "5. Push: git push -u origin main"
echo "6. Enable GitHub Pages in repository settings"
echo ""
echo "🌐 Your app will be available at: https://yourusername.github.io/vidyut/"
echo ""
echo "📁 Built files are in: build/web/"
echo "   You can test locally by opening build/web/index.html in a browser"
