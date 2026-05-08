# 🧠 MindMentor — Setup Guide

> Complete step-by-step tutorial to deploy MindMentor from zero to running on a local emulator with a live Supabase backend.

---

## Prerequisites

Before starting, ensure you have:

| Tool | Version | Install Link |
|------|---------|-------------|
| **Flutter SDK** | ≥ 3.41 | [flutter.dev/get-started](https://docs.flutter.dev/get-started/install) |
| **Supabase CLI** | ≥ 1.200 | [supabase.com/docs/guides/cli](https://supabase.com/docs/guides/cli/getting-started) |
| **Android Studio** or **VS Code** | Latest | [developer.android.com](https://developer.android.com/studio) |
| **Android Emulator** or **iOS Simulator** | — | Included with Android Studio / Xcode |

Verify installations:

```bash
flutter --version
supabase --version
```

---

## Step 1 — Create a Supabase Project

1. Go to [supabase.com/dashboard](https://supabase.com/dashboard)
2. Click **"New Project"**
3. Fill in:
   - **Organization**: Select or create one
   - **Project Name**: `mindmentor`
   - **Database Password**: Choose a strong password (save it securely)
   - **Region**: Choose the closest to your users
4. Click **"Create new project"** and wait ~2 minutes for provisioning

---

## Step 2 — Collect Your Credentials

Once the project is created, navigate to **Project Settings** (gear icon in sidebar):

### 2a. Project Reference ID

- Go to **Settings → General**
- Copy the **Reference ID** (looks like `abcdefghijklmnop`)

### 2b. API URL and Anon Key

- Go to **Settings → API**
- Copy:
  - **Project URL**: `https://abcdefghijklmnop.supabase.co`
  - **anon public** key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

> ⚠️ The **anon key** is safe for client-side use. Never expose the **service_role key**.

### 2c. Get an OpenRouter API Key

1. Go to [openrouter.ai](https://openrouter.ai)
2. Create an account and navigate to **Keys**
3. Click **"Create Key"**
4. Copy the key: `sk-or-v1-...`
5. Add credits ($5 minimum recommended for testing)

---

## Step 3 — Deploy with the Script

### Windows (PowerShell)

```powershell
cd F:\Flutter_Dev\MindMentor
.\deploy.ps1
```

### macOS / Linux (Bash)

```bash
cd /path/to/MindMentor
chmod +x deploy.sh
./deploy.sh
```

The script will interactively prompt you for:
1. ✏️ Supabase Project Reference ID
2. ✏️ Supabase Project URL
3. ✏️ Supabase Anon Key
4. ✏️ OpenRouter API Key

It then automatically:
1. Links your local project to Supabase
2. Pushes the database schema (4 tables with RLS)
3. Sets the OpenRouter API key as a Supabase secret
4. Deploys the `ai_proxy` Edge Function
5. Generates a local `.env` file

---

## Step 4 — Run the Flutter App

### Option A: Convenience Script (Recommended)

**Windows:**
```powershell
.\run.ps1
```

**macOS/Linux:**
```bash
chmod +x run.sh
./run.sh
```

This reads your `.env` file and passes credentials via `--dart-define`.

### Option B: Manual Command

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGci...
```

### Option C: VS Code Launch Configuration

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "MindMentor (Debug)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "toolArgs": [
        "--dart-define=SUPABASE_URL=https://your-project.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=your-anon-key"
      ]
    }
  ]
}
```

---

## Step 5 — Enable Auth (Optional but Recommended)

By default, the app requires Supabase Auth. To enable email/password login:

1. Go to **Supabase Dashboard → Authentication → Providers**
2. Ensure **Email** provider is enabled
3. Under **Authentication → Settings**:
   - Set **Site URL**: `http://localhost:3000` (or your domain)
   - Toggle **Enable email confirmations** OFF for development

To test without full auth during development, you can create a user via the Supabase Dashboard:
1. Go to **Authentication → Users**
2. Click **"Add User"** → **"Create New User"**
3. Enter an email and password

---

## Manual Deployment (Without Script)

If you prefer to run each step manually:

```bash
# 1. Link project
supabase link --project-ref YOUR_PROJECT_REF

# 2. Push database schema
supabase db push

# 3. Set Edge Function secret
supabase secrets set OPENROUTER_API_KEY=sk-or-v1-your-key

# 4. Deploy Edge Function
supabase functions deploy ai_proxy --no-verify-jwt

# 5. Run Flutter
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

---

## Project Architecture

```
MindMentor/
├── .env.example              ← Flutter env template
├── deploy.sh / deploy.ps1    ← Automated deployment
├── run.sh / run.ps1          ← Convenience run scripts
├── supabase/
│   ├── config.toml           ← Supabase CLI config
│   ├── .env.edge.example     ← Edge Function secrets template
│   ├── migrations/
│   │   └── 20260508000000_init_schema.sql  ← Database schema + RLS
│   └── functions/
│       ├── import_map.json   ← Shared Deno dependencies
│       └── ai_proxy/
│           ├── index.ts      ← Edge Function (AI proxy)
│           └── deno.jsonc    ← Deno config
├── backend/
│   └── schema.sql            ← Reference copy of schema
├── lib/                      ← Flutter application code
│   ├── main.dart
│   ├── core/                 ← Theme, routing, providers
│   ├── features/             ← Mood, chat, insights, emergency
│   └── shared/widgets/       ← Reusable UI components
└── test/                     ← Widget tests
```

---

## Security Checklist

| Check | Status |
|-------|--------|
| No API keys in `lib/` directory | ✅ |
| OpenRouter key stored as Supabase secret only | ✅ |
| All tables have RLS enabled | ✅ |
| RLS policies enforce `auth.uid() = user_id` | ✅ |
| JWT verified in Edge Function before AI call | ✅ |
| Crisis keywords detected client-side | ✅ |
| `.env` files in `.gitignore` | ✅ |

---

## Troubleshooting

### "Supabase URL is empty" at runtime
→ Ensure you're passing `--dart-define` flags. Use `run.ps1` or `run.sh`.

### Edge Function returns 401
→ The user must be authenticated. Create a test user in Supabase Dashboard → Auth → Users.

### Edge Function returns 502
→ Check your OpenRouter API key has credits. Verify with:
```bash
supabase secrets list
```

### "Connection refused" errors
→ Ensure your device/emulator has internet access and the Supabase URL is correct.

### Database tables not found
→ Run `supabase db push` again, or apply the schema manually via Supabase SQL Editor using `backend/schema.sql`.

---

## Next Steps

After getting the MVP running:

1. **Add Auth Screens** — Build login/register UI in `lib/features/auth/`
2. **Push Notifications** — Mood check-in reminders via FCM
3. **Dark Mode** — Extend `app_theme.dart` with `darkTheme`
4. **Analytics** — Add Sentry or PostHog for telemetry
5. **App Store Prep** — Custom icons, splash screen, app signing
