# svar_ai

Flutter client for SVAR AI.

## Auth setup (Supabase)

The app uses Supabase Auth with:

- **Google OAuth** (deep link: `com.svar.ai://login-callback/`)
- **Email magic link** (OTP fallback supported in-app)

In the Supabase Dashboard:

1. **Authentication → Providers → Email**
   - Enable Email
   - Turn **OFF** "Confirm email" (so new sign-ups get a session immediately)
2. **Authentication → Providers → Google**
   - Enable Google with your Google Cloud Client ID / Secret
3. **Authentication → URL Configuration → Redirect URLs**
   - `com.svar.ai://login-callback/`
   - `{your web site URL}/auth/callback`
   - `http://localhost:3000/auth/callback` (local web)
4. **Authentication → Email Templates → Magic Link**
   - Include `{{ .ConfirmationURL }}` for the deep link
   - Optionally also include `{{ .Token }}` so users can enter the 6-digit code in the app
5. **Project Settings → Authentication → SMTP** (recommended for production)
   - Configure custom SMTP (Resend, SendGrid, etc.) — Supabase's built-in mailer has strict rate limits (~1 email/minute) and emails often land in spam

## Release build (Google Play)

See [docs/PLAY_DEPLOY.md](docs/PLAY_DEPLOY.md) for keystore setup, production
`dart_defines/prod.json`, Play Console checklist, RevenueCat, and the 14-day
closed-testing requirement for personal developer accounts.

Quick build:

```bash
flutter build appbundle --release --dart-define-from-file=dart_defines/prod.json
```
