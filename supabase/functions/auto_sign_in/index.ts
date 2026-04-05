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

    // SUPABASE_SERVICE_ROLE_KEY is auto-provided by the Supabase runtime.
    // SERVICE_ROLE_KEY is the fallback if a custom secret was set manually.
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

    // Check if the user is verified
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

    // ── Generate a magic-link token via admin.generateLink ───────────────
    // This method is available in all supabase-js v2 versions and does NOT
    // send an email — it just creates a one-time token server-side.
    // The Flutter app will call verifyOTP(type: magiclink) with this token
    // to exchange it for a real session without any code entry by the user.
    const { data: linkData, error: linkError } = await supabaseAdmin.auth.admin.generateLink({
      type: 'magiclink',
      email: normalizedEmail,
      options: { shouldCreateUser: false },
    })

    if (linkError || !linkData?.properties?.hashed_token) {
      console.error('auto_sign_in: generateLink failed:', linkError?.message ?? 'no token returned')
      return new Response(
        JSON.stringify({ skip_otp: false, reason: `Failed to generate token: ${linkError?.message ?? 'unknown'}` }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Return the hashed_token — Flutter calls verifyOTP(type: magiclink) with it
    return new Response(
      JSON.stringify({
        skip_otp: true,
        token: linkData.properties.hashed_token,
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
