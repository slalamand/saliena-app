#!/bin/bash
# iOS Fix Script - Run this on a Mac
# This script will properly set up your iOS dependencies

echo "🔧 Fixing iOS dependencies..."

# Navigate to iOS directory
cd "$(dirname "$0")"

# Remove old pods
echo "📦 Removing old Pods..."
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec

# Update CocoaPods repo (optional, can be slow)
# echo "🔄 Updating CocoaPods repo..."
# pod repo update

# Install pods
echo "📥 Installing CocoaPods dependencies..."
pod install --repo-update

# Verify installation
if [ -d "Pods" ]; then
    echo "✅ Pods installed successfully!"
    echo "📱 You can now open Runner.xcworkspace in Xcode"
else
    echo "❌ Pod installation failed!"
    echo "Try running: pod install --verbose"
    exit 1
fi

echo "🎉 iOS setup complete!"
