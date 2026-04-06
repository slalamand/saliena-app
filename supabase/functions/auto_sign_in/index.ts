import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
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

    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const serviceRoleKey =
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ??
      Deno.env.get('SERVICE_ROLE_KEY') ??
      ''

    if (!supabaseUrl || !serviceRoleKey) {
      console.error('auto_sign_in: missing SUPABASE_URL or service role key')
      return new Response(
        JSON.stringify({ skip_otp: false, reason: 'Server configuration error' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey, {
      auth: { autoRefreshToken: false, persistSession: false }
    })

    const normalizedEmail = email.toLowerCase().trim()

    // ── Step 1: Check the profiles table for this email ──────────────────────
    // Only management-approved users have a profile row. If not found → reject.
    const { data: profile, error: profileError } = await supabaseAdmin
      .from('profiles')
      .select('id, is_verified')
      .eq('email', normalizedEmail)
      .single()

    if (profileError || !profile) {
      console.error('auto_sign_in: profile lookup failed:', profileError?.message ?? 'user not found')
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

    // ── Step 2: Generate a magic-link token server-side ───────────────────────
    // generateLink does NOT send an email — it only creates a one-time token.
    // The Flutter app will call verifyOTP(type: magiclink, token: rawToken)
    // to exchange it for a real Supabase session.
    const { data: linkData, error: linkError } = await supabaseAdmin.auth.admin.generateLink({
      type: 'magiclink',
      email: normalizedEmail,
      options: { shouldCreateUser: false },
    })

    if (linkError || !linkData?.properties?.action_link) {
      console.error('auto_sign_in: generateLink failed:', linkError?.message ?? 'no action_link returned')
      return new Response(
        JSON.stringify({ skip_otp: false, reason: `Failed to generate token: ${linkError?.message ?? 'unknown'}` }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // ── Step 3: Extract the RAW token from the action_link URL ────────────────
    //
    // IMPORTANT: generateLink returns two token-related fields:
    //   • properties.hashed_token  — the SHA-256 hash stored in the DB (do NOT use)
    //   • properties.action_link   — the actual magic-link URL that contains the
    //                                RAW token as a query parameter
    //
    // verifyOTP(type: magiclink) on the client sends the raw token to
    // /auth/v1/verify, which then SHA-256-hashes it and compares to the DB.
    // Sending hashed_token would hash it twice → verification failure.
    //
    // We parse the action_link URL and pull out the ?token= parameter.
    let rawToken: string | null = null
    try {
      const actionUrl = new URL(linkData.properties.action_link)
      rawToken = actionUrl.searchParams.get('token')
    } catch (parseError) {
      console.error('auto_sign_in: failed to parse action_link URL:', parseError)
    }

    if (!rawToken) {
      console.error('auto_sign_in: could not extract raw token from action_link')
      return new Response(
        JSON.stringify({ skip_otp: false, reason: 'Failed to extract token from magic link' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log(`auto_sign_in: successfully generated token for ${normalizedEmail}`)

    // Return the raw token — Flutter calls verifyOTP(type: OtpType.magiclink)
    return new Response(
      JSON.stringify({
        skip_otp: true,
        token: rawToken,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('auto_sign_in: unhandled error:', String(error))
    return new Response(
      JSON.stringify({ skip_otp: false, reason: `Internal error: ${String(error)}` }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
