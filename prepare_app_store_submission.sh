#!/bin/bash

# ============================================================================
# SALIENA ESTATE APP - APP STORE SUBMISSION PREPARATION SCRIPT
# ============================================================================
# This script helps prepare your Flutter app for Apple App Store submission
# Run this script before creating your final build for submission
# ============================================================================

set -e  # Exit on any error

echo "🍎 Preparing Saliena Estate App for App Store Submission..."
echo "============================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. Please run this script from the Flutter project root."
    exit 1
fi

print_status "Checking Flutter project structure..."

# 1. Clean the project
print_status "Cleaning Flutter project..."
flutter clean
print_success "Project cleaned"

# 2. Get dependencies
print_status "Getting Flutter dependencies..."
flutter pub get
print_success "Dependencies updated"

# 3. Check for common issues
print_status "Running pre-submission checks..."

# Check for debug prints
print_status "Checking for debug print statements..."
if grep -r "print(" lib/ --include="*.dart" > /dev/null 2>&1; then
    print_warning "Found print() statements in code. Consider removing for production:"
    grep -r "print(" lib/ --include="*.dart" | head -5
else
    print_success "No debug print statements found"
fi

# Check for debugPrint
if grep -r "debugPrint(" lib/ --include="*.dart" > /dev/null 2>&1; then
    print_warning "Found debugPrint() statements in code. These are OK but consider reviewing:"
    grep -r "debugPrint(" lib/ --include="*.dart" | head -3
fi

# Check for TODO comments
print_status "Checking for TODO comments..."
if grep -r "TODO" lib/ --include="*.dart" > /dev/null 2>&1; then
    print_warning "Found TODO comments. Consider addressing before submission:"
    grep -r "TODO" lib/ --include="*.dart" | head -5
else
    print_success "No TODO comments found"
fi

# 4. Check iOS configuration
print_status "Checking iOS configuration..."

if [ ! -f "ios/Runner/Info.plist" ]; then
    print_error "iOS Info.plist not found"
    exit 1
fi

# Check for permission descriptions
print_status "Checking iOS permission descriptions..."
required_permissions=(
    "NSLocationWhenInUseUsageDescription"
    "NSCameraUsageDescription"
    "NSPhotoLibraryUsageDescription"
    "NSMicrophoneUsageDescription"
)

for permission in "${required_permissions[@]}"; do
    if grep -q "$permission" ios/Runner/Info.plist; then
        print_success "✓ $permission found"
    else
        print_error "✗ $permission missing from Info.plist"
    fi
done

# Check for privacy manifest
if [ -f "ios/Runner/PrivacyInfo.xcprivacy" ]; then
    print_success "✓ Privacy manifest found"
else
    print_warning "Privacy manifest (PrivacyInfo.xcprivacy) not found. This may be required."
fi

# 5. Analyze code
print_status "Running Flutter analyze..."
if flutter analyze; then
    print_success "Code analysis passed"
else
    print_warning "Code analysis found issues. Please review and fix."
fi

# 6. Check app icons
print_status "Checking app icons..."
if [ -f "assets/icons/Light-Logo-Saliena.png" ]; then
    print_success "✓ App icon found"
else
    print_error "✗ App icon not found at assets/icons/Light-Logo-Saliena.png"
fi

# 7. Check environment file
print_status "Checking environment configuration..."
if [ -f ".env" ]; then
    print_success "✓ Environment file found"
    if grep -q "SUPABASE_URL" .env && grep -q "SUPABASE_ANON_KEY" .env; then
        print_success "✓ Supabase configuration found"
    else
        print_error "✗ Supabase configuration incomplete in .env"
    fi
else
    print_error "✗ .env file not found"
fi

# 8. Build iOS app for testing
print_status "Building iOS app for testing..."
if flutter build ios --release --no-codesign --dart-define-from-file=.env; then
    print_success "iOS build successful"
else
    print_error "iOS build failed. Please fix build errors before submission."
    exit 1
fi

# 9. Generate app icons (if flutter_launcher_icons is configured)
print_status "Generating app icons..."
if flutter pub run flutter_launcher_icons; then
    print_success "App icons generated"
else
    print_warning "App icon generation failed or not configured"
fi

# 10. Generate native splash screens
print_status "Generating splash screens..."
if flutter pub run flutter_native_splash:create; then
    print_success "Splash screens generated"
else
    print_warning "Splash screen generation failed or not configured"
fi

echo ""
echo "============================================================"
print_success "Pre-submission preparation completed!"
echo "============================================================"
echo ""

print_status "Next steps:"
echo "1. Open Xcode and create an Archive build"
echo "2. Upload to App Store Connect"
echo "3. Complete App Store Connect metadata"
echo "4. Submit for review"
echo ""

print_status "Important reminders:"
echo "• Create demo account for Apple reviewers"
echo "• Complete privacy labels in App Store Connect"
echo "• Upload required screenshots"
echo "• Test the demo account login flow"
echo "• Review the submission checklist"
echo ""

print_status "Demo account setup:"
echo "Run this SQL in Supabase: supabase/sql/08_create_demo_account.sql"
echo ""

print_success "Good luck with your App Store submission! 🚀"