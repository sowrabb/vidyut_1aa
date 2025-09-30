#!/bin/bash

echo "🚀 Manual GitHub Pages Deployment"
echo "=================================="

# Build the app
echo "📦 Building Flutter web app..."
flutter build web --release

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Navigate to build directory
    cd build/web
    
    # Initialize git if not already done
    if [ ! -d ".git" ]; then
        echo "🔧 Initializing git repository..."
        git init
        git checkout -b gh-pages
    fi
    
    # Add all files
    echo "📁 Adding files..."
    git add .
    
    # Commit
    echo "💾 Committing changes..."
    git commit -m "Deploy Flutter web app - $(date)"
    
    # Add remote if not exists
    echo "🔗 Setting up remote..."
    git remote remove origin 2>/dev/null || true
    git remote add origin https://github.com/sowrabb/vidyut5.git
    
    # Push to gh-pages branch
    echo "🚀 Deploying to GitHub Pages..."
    git push origin gh-pages --force
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 SUCCESS! Your app is now deployed!"
        echo "🔗 Live URL: https://sowrabb.github.io/vidyut5/"
        echo "📱 Share this with your client!"
        echo ""
        echo "⏳ Note: It may take 5-10 minutes for the site to be fully accessible"
        echo "🔄 Refresh the page after a few minutes"
    else
        echo "❌ Deployment failed. Please check your GitHub repository settings."
        echo "🔧 Make sure GitHub Pages is enabled in repository settings"
    fi
else
    echo "❌ Build failed. Please fix the errors and try again."
    exit 1
fi
