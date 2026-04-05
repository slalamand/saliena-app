import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { email } = await req.json()

    if (!email) {
      return new Response(
        JSON.stringify({ error: 'Email is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // SUPABASE_URL is always auto-provided by Supabase Edge Functions.
    // SUPABASE_SERVICE_ROLE_KEY is also auto-provided (Supabase reserves the
    // SUPABASE_ prefix). We fall back to SERVICE_ROLE_KEY in case a custom
    // secret with that name was configured manually.
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const serviceRoleKey =
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ??
      Deno.env.get('SERVICE_ROLE_KEY') ??
      ''

    if (!supabaseUrl || !serviceRoleKey) {
      console.error(
        'auto_sign_in: missing env — SUPABASE_URL or service role key not available.',
        'SUPABASE_URL present:', !!supabaseUrl,
        'key present:', !!serviceRoleKey,
      )
      return new Response(
        JSON.stringify({ skip_otp: false, reason: 'Server configuration error' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Use service role key (server-side only — never exposed to client)
    const supabaseAdmin = createClient(
      supabaseUrl,
      serviceRoleKey,
      { auth: { autoRefreshToken: false, persistSession: false } }
    )

    const normalizedEmail = email.toLowerCase().trim()

    // Check if the user is verified and get their user ID in one query
    const { data: profile, error: profileError } = await supabaseAdmin
      .from('profiles')
      .select('id, is_verified')
      .eq('email', normalizedEmail)
      .single()

    if (profileError || !profile) {
      console.error('auto_sign_in: profile lookup failed:', profileError?.message ?? 'user not found', 'email:', normalizedEmail)
      return new Response(
        JSON.stringify({ skip_otp: false, reason: 'User not found' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (!profile.is_verified) {
      return new Response(
        JSON.stringify({ skip_otp: false, reason: 'User not verified' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // ── Create a real session directly via admin API ─────────────────────
    // admin.createSession() bypasses the OTP rate limiter entirely.
    // No magic link is generated, no email is sent, no 60-second cooldown.
    const { data: sessionData, error: sessionError } = await supabaseAdmin.auth.admin.createSession({
      user_id: profile.id,
    })

    if (sessionError || !sessionData?.session) {
      console.error('auto_sign_in: createSession failed:', sessionError?.message ?? 'no session returned')
      return new Response(
        JSON.stringify({ skip_otp: false, reason: 'Failed to create session' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Return the refresh token — the Flutter app calls setSession(refreshToken)
    // to exchange it for a live session (not subject to OTP rate limits).
    return new Response(
      JSON.stringify({
        skip_otp: true,
        refresh_token: sessionData.session.refresh_token,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('auto_sign_in: unhandled error:', error)
    return new Response(
      JSON.stringify({ skip_otp: false, reason: 'Internal error' }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
