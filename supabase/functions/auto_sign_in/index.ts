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

    // ── Step 2: Ensure the user's email is confirmed in auth.users ─────────────
    // generateLink requires a confirmed email. Verified residents may have been
    // created via the dashboard without going through normal email confirmation,
    // so we force-confirm here using the service-role key.
    const { error: confirmError } = await supabaseAdmin.auth.admin.updateUserById(
      profile.id,
      { email_confirm: true }
    )
    if (confirmError) {
      console.warn('auto_sign_in: could not confirm email (non-fatal):', confirmError.message)
    }

    // ── Step 3: Generate a one-time OTP server-side ───────────────────────────
    // generateLink does NOT send an email — it just creates a token pair.
    // We use the email_otp field (6-digit code) and verify it with
    // OtpType.email on the Flutter side — this path has no PKCE requirement
    // and is the same proven code path used during normal OTP login.
    //
    // WHY NOT magiclink type: GoTrue v2.188+ requires PKCE for magic links,
    // so verifyOTP(type: magiclink, token) always fails on this server version.
    const { data: linkData, error: linkError } = await supabaseAdmin.auth.admin.generateLink({
      type: 'magiclink',
      email: normalizedEmail,
      options: { shouldCreateUser: false },
    })

    if (linkError || !linkData?.properties) {
      console.error('auto_sign_in: generateLink failed:', linkError?.message ?? 'no properties returned')
      return new Response(
        JSON.stringify({ skip_otp: false, reason: `Failed to generate OTP: ${linkError?.message ?? 'unknown'}` }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // email_otp is the 6-digit code embedded in OTP emails as {{ .Token }}
    const emailOtp = linkData.properties.email_otp

    if (!emailOtp) {
      console.error('auto_sign_in: no email_otp in generateLink response')
      return new Response(
        JSON.stringify({ skip_otp: false, reason: 'OTP code not returned by server' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log(`auto_sign_in: successfully generated OTP for ${normalizedEmail}`)

    // Return the 6-digit OTP — Flutter calls verifyOTP(type: OtpType.email)
    return new Response(
      JSON.stringify({
        skip_otp: true,
        email_otp: emailOtp,
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
