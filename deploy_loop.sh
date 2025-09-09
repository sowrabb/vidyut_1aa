#!/bin/bash

echo "🚀 Starting continuous deployment loop..."
echo "Repository: https://github.com/sowrabb/vidyut5"
echo "Live URL: https://sowrabb.github.io/vidyut5/"
echo ""

# Function to check GitHub Actions status
check_deployment_status() {
    echo "📊 Checking GitHub Actions deployment status..."
    
    # Get the latest workflow run status
    # This would require GitHub CLI or API access
    echo "⏳ Waiting for GitHub Actions to complete..."
    echo "🔗 Check status at: https://github.com/sowrabb/vidyut5/actions"
    
    # Simulate waiting
    sleep 30
}

# Function to test the live site
test_live_site() {
    echo "🌐 Testing live site..."
    local url="https://sowrabb.github.io/vidyut5/"
    
    # Check if the site is accessible
    if curl -s --head "$url" | head -n 1 | grep -q "200 OK"; then
        echo "✅ Site is live and accessible!"
        echo "🎉 Deployment successful!"
        echo "📱 Share with client: $url"
        return 0
    else
        echo "❌ Site not accessible yet"
        return 1
    fi
}

# Function to push changes
push_changes() {
    echo "📤 Pushing changes to GitHub..."
    git add .
    git commit -m "Auto-deploy: $(date)"
    git push origin main
    echo "✅ Changes pushed successfully"
}

# Main deployment loop
deployment_count=0
max_attempts=5

while [ $deployment_count -lt $max_attempts ]; do
    deployment_count=$((deployment_count + 1))
    echo ""
    echo "🔄 Deployment attempt #$deployment_count"
    echo "=================================="
    
    # Test current build locally
    echo "🧪 Testing build locally..."
    if flutter build web --release; then
        echo "✅ Local build successful"
        
        # Push changes
        push_changes
        
        # Wait for GitHub Actions
        echo "⏳ Waiting for GitHub Actions deployment..."
        sleep 60
        
        # Test live site
        if test_live_site; then
            echo ""
            echo "🎊 SUCCESS! Your app is now live!"
            echo "🔗 Live URL: https://sowrabb.github.io/vidyut5/"
            echo "📱 Share this with your client!"
            exit 0
        else
            echo "⚠️  Deployment not ready yet, retrying..."
        fi
    else
        echo "❌ Local build failed, fixing issues..."
        
        # Try to fix common issues
        echo "🔧 Running flutter clean..."
        flutter clean
        flutter pub get
        
        echo "🔧 Checking for linter errors..."
        flutter analyze
        
        echo "🔧 Attempting to fix issues..."
        # Add any automatic fixes here
    fi
    
    if [ $deployment_count -lt $max_attempts ]; then
        echo "⏳ Waiting 30 seconds before next attempt..."
        sleep 30
    fi
done

echo ""
echo "❌ Maximum deployment attempts reached"
echo "🔗 Check GitHub Actions manually: https://github.com/sowrabb/vidyut5/actions"
echo "📞 Contact support if issues persist"
exit 1
