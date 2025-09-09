#!/bin/bash

echo "🔥 Firebase Hosting Deployment"
echo "=============================="

# Build the Flutter web app
echo "📦 Building Flutter web app..."
flutter build web --release

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Deploy to Firebase Hosting
    echo "🚀 Deploying to Firebase Hosting..."
    firebase deploy --only hosting
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 SUCCESS! Your app is now live on Firebase!"
        echo "🔗 Live URL: https://vidyut1.web.app"
        echo "📱 Share this with your client!"
        echo ""
        echo "🔄 To update: Run this script again"
    else
        echo "❌ Firebase deployment failed"
        exit 1
    fi
else
    echo "❌ Build failed. Please fix the errors and try again."
    exit 1
fi
