import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

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

    // Use service role key (server-side only — never exposed to client)
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SERVICE_ROLE_KEY') ?? '',
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
    // This uses admin.createSession() which bypasses the OTP rate limiter
    // entirely. No magic link is generated, no email is sent, no 60-second
    // cooldown applies. The session is created in Supabase's session store
    // and the refresh token is returned to the app.
    const { data: sessionData, error: sessionError } = await supabaseAdmin.auth.admin.createSession({
      user_id: profile.id,
    })

    if (sessionError || !sessionData?.session) {
      console.error('createSession error:', sessionError)
      return new Response(
        JSON.stringify({ skip_otp: false, reason: 'Failed to create session' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Return the refresh token — the Flutter app calls setSession(refreshToken)
    // which exchanges it at /auth/v1/token?grant_type=refresh_token (no rate limit).
    return new Response(
      JSON.stringify({
        skip_otp: true,
        refresh_token: sessionData.session.refresh_token,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('auto_sign_in error:', error)
    return new Response(
      JSON.stringify({ skip_otp: false, reason: 'Internal error' }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
