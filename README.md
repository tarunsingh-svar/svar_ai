# svar_ai

Flutter client for SVAR AI.

## Auth setup (Supabase)

The app uses Supabase Auth with:

- **Google OAuth** (deep link: `com.svar.ai://login-callback/`)
- **Email + password** (sign-in / sign-up; no magic link)

In the Supabase Dashboard:

1. **Authentication → Providers → Email**
   - Enable Email
   - Turn **OFF** "Confirm email" (so new sign-ups get a session immediately)
   - Set a minimum password length (recommended: 8)
2. **Authentication → Providers → Google**
   - Enable Google with your Google Cloud Client ID / Secret
3. **Authentication → URL Configuration → Redirect URLs**
   - `com.svar.ai://login-callback/`
   - `{your web site URL}/auth/callback`
   - `http://localhost:3000/auth/callback` (local web)

## Getting Started

Use `--dart-define-from-file` with a JSON file that includes `SUPABASE_URL` and
`SUPABASE_ANON_KEY` (see `dart_defines/example.json`).
