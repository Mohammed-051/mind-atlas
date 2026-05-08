# 🚀 MindMentor — Launch Checklist

> Everything you need to do before submitting MindMentor to the App Store and Google Play.

---

## ✅ Pre-Submission Checklist

### 1. Branding Assets
- [ ] **Replace placeholder icon** — swap `assets/images/icon.png` with final logo (1024×1024 PNG, no transparency for iOS)
- [ ] **Create foreground icon** — adaptive icon foreground at `assets/images/icon_foreground.png` (432×432 with padding)
- [ ] **Regenerate native icons** — run `flutter pub run flutter_launcher_icons`
- [ ] **Add splash logo** — add `image` key to `flutter_native_splash` config in `pubspec.yaml`, then run `flutter pub run flutter_native_splash:create`
- [ ] **Prepare store screenshots** — 3-5 screenshots per device size (phone + tablet)
- [ ] **Create feature graphic** — 1024×500 for Google Play listing

### 2. Environment & Secrets
- [ ] **GitHub Actions secrets** — set these in your repo `Settings > Secrets`:
  - `SUPABASE_URL` — your Supabase project URL
  - `SUPABASE_ANON_KEY` — your Supabase anon key
  - `SENTRY_DSN` — your Sentry project DSN
- [ ] **Verify `.env` is gitignored** — confirm secrets are NEVER committed
- [ ] **Test production build** locally:
  ```powershell
  flutter build apk --release `
    --dart-define=SUPABASE_URL=<your-url> `
    --dart-define=SUPABASE_ANON_KEY=<your-key> `
    --dart-define=SENTRY_DSN=<your-dsn>
  ```

### 3. Sentry Telemetry
- [ ] **Create Sentry project** at [sentry.io](https://sentry.io)
- [ ] **Copy DSN** from `Settings > Client Keys`
- [ ] **Add DSN to build** via `--dart-define=SENTRY_DSN=your-dsn`
- [ ] **Verify crash reporting** — trigger a test error and confirm it appears in Sentry dashboard

### 4. Backend Verification
- [ ] **Supabase Auth** — confirm email sign-up works with email confirmation flow
- [ ] **Edge Function** — test `ai_proxy` returns valid responses: `supabase functions serve ai_proxy`
- [ ] **RLS Policies** — verify users cannot access other users' data
- [ ] **Database migration** — confirm `supabase db push` applies cleanly

### 5. Google Play Console
- [ ] **Create developer account** ($25 one-time fee) at [play.google.com/console](https://play.google.com/console)
- [ ] **Create new app** → select "App" → enter app details
- [ ] **Content rating** — complete the IARC questionnaire (mental health category)
- [ ] **Privacy policy** — required for apps collecting personal data. Host at a public URL.
- [ ] **Target audience** — set to 18+ (mental health content)
- [ ] **App signing** — enroll in Google Play App Signing
- [ ] **Upload AAB** — build with `flutter build appbundle --release` and upload
- [ ] **Fill store listing** — title, description, screenshots, feature graphic, category (Health & Fitness)
- [ ] **Submit for review**

### 6. App Store Connect (iOS)
- [ ] **Apple Developer Program** ($99/year) at [developer.apple.com](https://developer.apple.com)
- [ ] **Create App ID** in Certificates, Identifiers & Profiles
- [ ] **Create provisioning profile** for distribution
- [ ] **Configure Xcode signing** — set Team and Bundle Identifier
- [ ] **Build archive** — `flutter build ipa --release`
- [ ] **Upload via Transporter** or Xcode Organizer
- [ ] **App Store listing** — title, subtitle, description, screenshots, keywords
- [ ] **App Review Information** — provide demo account credentials for reviewers
- [ ] **Privacy nutrition labels** — declare data types collected (email, mood data, chat messages)
- [ ] **Submit for review**

### 7. Post-Launch
- [ ] **Monitor Sentry dashboard** for crashes in first 48 hours
- [ ] **Check Supabase usage** — monitor Edge Function invocations and DB connections
- [ ] **Respond to user reviews** promptly
- [ ] **Plan v1.1** — push notifications, breathing exercises, data export

---

## 📋 App Store Metadata

| Field | Value |
|-------|-------|
| **App Name** | MindMentor |
| **Subtitle** | AI Mental Well-being Companion |
| **Category** | Health & Fitness |
| **Age Rating** | 17+ (mental health content) |
| **Price** | Free |
| **Availability** | Worldwide |

### Suggested Description
> MindMentor is your compassionate AI companion for mental well-being. Track your daily mood, gain insights into your emotional patterns, and chat with an empathetic AI that's always here to listen — privately and securely.
>
> Features:
> • AI-powered empathetic conversations
> • Daily mood tracking with visual insights
> • Beautiful monthly mood calendar
> • Crisis intervention with 988 Lifeline integration
> • Dark mode for comfortable nighttime use
> • End-to-end privacy — your data stays yours

---

## ⚠️ Important Notes

> **Crisis Feature**: Ensure the emergency screen with 988 Lifeline resources is always accessible. App reviewers may test this.

> **Privacy Policy**: Required for both stores. Must disclose: email collection, mood data storage, AI chat processing, and Sentry crash reporting.

> **Medical Disclaimer**: Include a disclaimer that MindMentor is NOT a substitute for professional medical advice, diagnosis, or treatment.
