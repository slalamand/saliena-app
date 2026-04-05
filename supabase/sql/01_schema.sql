-- ============================================================================
-- SALIENA APP - DATABASE SCHEMA
-- ============================================================================
-- Description: Complete database schema for Saliena municipality reporting app
-- Version: 1.2.0 (Updated with video support and optional media)
-- Run Order: 1 (Run this first)
-- ============================================================================

-- ============================================================================
-- STEP 1: ENABLE EXTENSIONS
-- ============================================================================

-- Enable UUID generation (required for primary keys)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- STEP 2: CREATE CUSTOM TYPES (ENUMS)
-- ============================================================================

-- User roles: defines what users can do in the system
-- - resident: Regular users who can submit reports
-- - worker: Municipality workers who can update report status
-- - office_admin: Administrators with full access
CREATE TYPE user_role AS ENUM ('resident', 'worker', 'office_admin');

-- Report status: lifecycle of a report
-- - pending: Just submitted, awaiting review
-- - in_progress: Being worked on by a worker
-- - fixed: Completed and resolved
CREATE TYPE report_status AS ENUM ('pending', 'in_progress', 'fixed');

-- ============================================================================
-- STEP 3: CREATE TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- PROFILES TABLE
-- ----------------------------------------------------------------------------
-- Extends auth.users with app-specific profile data
-- One-to-one relationship with auth.users
CREATE TABLE IF NOT EXISTS public.profiles (
    -- Primary key (matches auth.users.id)
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Basic user information
    email TEXT NOT NULL,
    phone TEXT,
    full_name TEXT NOT NULL,
    address TEXT,
    
    -- Role and permissions
    role user_role NOT NULL DEFAULT 'resident',
    
    -- Verification status (synced with auth.users.email_confirmed_at)
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    
    -- Two-factor authentication (DEPRECATED - using email OTP only)
    two_factor_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    
    -- Profile picture
    avatar_url TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE public.profiles IS 'User profiles for Saliena Support. Authentication uses email OTP only. Verification is automatic via email_confirmed_at.';

-- Indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_is_verified ON public.profiles(is_verified);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);

-- ----------------------------------------------------------------------------
-- REPORTS TABLE
-- ----------------------------------------------------------------------------
-- Stores all municipality issue reports submitted by users
CREATE TABLE IF NOT EXISTS public.reports (
    -- Primary key
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Reporter (who submitted this report)
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    
    -- Report content
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    
    -- Media (OPTIONAL - reports can be submitted without media)
    photo_url TEXT,  -- Can be single URL or pipe-separated (|||) for multiple photos (max 3)
    video_url TEXT,  -- Single video URL (max 15 seconds, 10MB)
    
    -- Location data
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    address TEXT,
    location_source TEXT NOT NULL DEFAULT 'device_gps' 
        CHECK (location_source IN ('photo_exif', 'device_gps', 'manual')),
    
    -- Status tracking
    status report_status NOT NULL DEFAULT 'pending',
    fixed_by UUID REFERENCES public.profiles(id),
    fixed_at TIMESTAMPTZ,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE public.reports IS 'Municipality issue reports with optional photo/video evidence and GPS location.';
COMMENT ON COLUMN public.reports.photo_url IS 'URL(s) to uploaded photos (optional). Can be single URL or pipe-separated (|||) for multiple photos. Maximum 3 photos per report.';
COMMENT ON COLUMN public.reports.video_url IS 'URL to uploaded video (optional). Maximum 15 seconds, 10MB file size.';
COMMENT ON COLUMN public.reports.location_source IS 'Source of location data: photo_exif (from photo metadata), device_gps (from device), or manual (user-selected).';

-- Indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_reports_user_id ON public.reports(user_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON public.reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON public.reports(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reports_location ON public.reports(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_reports_fixed_by ON public.reports(fixed_by);

-- ----------------------------------------------------------------------------
-- NOTIFICATIONS TABLE
-- ----------------------------------------------------------------------------
-- Stores in-app notifications for users
CREATE TABLE IF NOT EXISTS public.notifications (
    -- Primary key
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Recipient
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    
    -- Notification content
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    data JSONB,
    
    -- Status
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    
    -- Timestamp
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.notifications IS 'In-app notifications for users about report status changes and system messages.';

-- Indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);

-- ----------------------------------------------------------------------------
-- USER_ROLES TABLE (HELPER TABLE)
-- ----------------------------------------------------------------------------
-- Simple helper table for role lookups
CREATE TABLE IF NOT EXISTS public.user_roles (
    id UUID PRIMARY KEY,
    role user_role NOT NULL
);

COMMENT ON TABLE public.user_roles IS 'Helper table for role-based queries and lookups.';

-- ============================================================================
-- STEP 4: ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- SCHEMA SETUP COMPLETE
-- ============================================================================
-- 
-- What's included:
-- ✅ User profiles with role-based access
-- ✅ Reports with optional photo/video support
-- ✅ GPS location tracking (photo EXIF or device GPS)
-- ✅ Notifications system
-- ✅ Row Level Security enabled
-- 
-- Media Limits:
-- - Photos: Up to 3 per report (optional)
-- - Video: 1 per report, 15 seconds max, 10MB max (optional)
-- - Reports can be submitted without any media
-- 
-- Next steps:
-- 1. Run 02_functions.sql to create database functions and triggers
-- 2. Run 03_rls_policies.sql to set up security policies
-- 3. Run 04_storage.sql to configure file storage
-- 4. Run 05_seed_data.sql to add test data (optional)
-- 5. Run 06_auth_config.sql to configure authentication
-- 
-- ============================================================================
