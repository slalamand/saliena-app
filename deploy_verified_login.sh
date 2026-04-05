#!/bin/bash

# Deployment script for verified user login feature
# This script deploys the SQL function and Edge Function to Supabase

set -e  # Exit on error

echo "🚀 Deploying Verified User Login Feature"
echo "=========================================="
echo ""

# Check if Supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI is not installed"
    echo "📦 Install it with: npm install -g supabase"
    exit 1
fi

echo "✅ Supabase CLI found"
echo ""

# Get project ref from .env file
PROJECT_REF="eaydzmsghcylzryfezab"
echo "📋 Project: $PROJECT_REF"
echo ""

# Check if user is logged in
echo "🔐 Checking Supabase login status..."
if ! supabase projects list &> /dev/null; then
    echo "❌ Not logged in to Supabase"
    echo "🔑 Please run: supabase login"
    exit 1
fi

echo "✅ Logged in to Supabase"
echo ""

# Link project if not already linked
echo "🔗 Linking project..."
supabase link --project-ref $PROJECT_REF || echo "Already linked"
echo ""

# Deploy Edge Function
echo "📤 Deploying auto_sign_in Edge Function..."
supabase functions deploy auto_sign_in
echo "✅ Edge Function deployed"
echo ""

# Deploy SQL function
echo "📤 Deploying SQL function..."
echo "⚠️  You need to manually run the SQL in Supabase Dashboard:"
echo "   1. Go to: https://$PROJECT_REF.supabase.co"
echo "   2. Navigate to SQL Editor"
echo "   3. Run the contents of: supabase/sql/09_verified_login.sql"
echo ""

echo "✅ Deployment complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Run the SQL function in Supabase Dashboard (see above)"
echo "   2. Verify user is marked as verified in profiles table"
echo "   3. Test login with: reviewer@saliena-demo.com"
echo ""
