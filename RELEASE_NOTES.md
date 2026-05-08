# 🧠 MindMentor — Release Notes v1.0.0

> A premium AI-powered mental well-being companion.

---

## ✨ Features

### 🎯 Core Features
- **AI Chat Companion** — Empathetic, context-aware conversations powered by Claude 3 Haiku via OpenRouter
- **Mood Tracking** — Interactive daily mood logging with 5-point scale and optional notes
- **Insights Dashboard** — Monthly calendar view with mood markers, averages, and trend visualization
- **Emergency Protocol** — Mandatory crisis intervention system detecting self-harm keywords, locking chat, and routing to 988 Suicide & Crisis Lifeline

### 🔐 Authentication & Security
- **Supabase Auth** — Email/password sign-in and registration
- **Route Guards** — Protected routes with automatic redirect for unauthenticated users
- **Row Level Security** — All database tables enforce `auth.uid() = user_id`
- **Zero Hardcoded Secrets** — Credentials injected via `--dart-define` at build time
- **Edge Function Proxy** — OpenRouter API key never touches the client

### 🎨 Premium UI/UX
- **Onboarding Flow** — 3-slide PageView introducing app values with animated dot indicators
- **Dark Mode** — System-adaptive theming with soothing midnight blues (NOT pure black)
- **Glass Card Components** — Frosted glass aesthetic throughout
- **Elastic Animations** — Press-scale pill buttons, fade transitions, typing indicators
- **Google Fonts (Inter)** — Clean, professional typography

### 🏗️ Architecture
- **State Management** — Riverpod (StateNotifier + AsyncNotifier)
- **Navigation** — GoRouter with ShellRoute + auth/onboarding redirect guards
- **Backend** — Supabase (PostgreSQL + Auth + Edge Functions)
- **AI Engine** — Deno Edge Function → OpenRouter → Claude 3 Haiku

---

## 📱 Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.41+ (Dart) |
| State | flutter_riverpod 2.6 |
| Routing | go_router 14.8 |
| Backend | Supabase (PostgreSQL + Auth + Edge Functions) |
| AI Proxy | Deno Edge Function → OpenRouter (Claude 3 Haiku) |
| Storage | flutter_secure_storage 9.2 |
| Typography | google_fonts (Inter) |
| Animations | flutter_animate 4.5 |

---

## 🚀 Deployment

### Prerequisites
- Flutter SDK ≥ 3.41
- Supabase CLI ≥ 1.200
- Supabase project + OpenRouter API key

### Quick Start
```powershell
# 1. Install Supabase CLI and login
supabase login

# 2. Deploy backend
.\deploy.ps1

# 3. Run the app
.\run.ps1
```

See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed instructions.

---

## 📁 Project Structure

```
MindMentor/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── models/          ← MoodLog, ChatMessage
│   │   ├── providers/       ← Auth, Supabase providers
│   │   ├── routing/         ← GoRouter with guards
│   │   └── theme/           ← Light + Dark themes
│   ├── features/
│   │   ├── auth/            ← Login, Register screens
│   │   ├── onboarding/      ← 3-slide intro flow
│   │   ├── mood/            ← Home + mood logging
│   │   ├── chat/            ← AI chat + crisis detection
│   │   ├── insights/        ← Monthly calendar
│   │   └── emergency/       ← 988 Crisis Lifeline
│   └── shared/widgets/      ← GlassCard, PillButton, etc.
├── supabase/
│   ├── config.toml
│   ├── migrations/           ← Database schema + RLS
│   └── functions/ai_proxy/   ← Deno Edge Function
├── deploy.sh / deploy.ps1    ← Automated deployment
├── run.sh / run.ps1          ← Convenience runners
└── SETUP_GUIDE.md            ← Step-by-step tutorial
```

---

## 🛡️ Safety & Compliance

| Requirement | Status |
|-------------|--------|
| Crisis keyword detection (client-side) | ✅ |
| Chat lock on crisis detection | ✅ |
| 988 Lifeline integration | ✅ |
| No medical diagnoses from AI | ✅ (system prompt enforced) |
| No medication recommendations | ✅ (system prompt enforced) |
| RLS on all tables | ✅ |
| JWT verification on Edge Function | ✅ |

---

## 📋 Next Steps (Post-MVP)

1. **Push Notifications** — Daily mood check-in reminders via FCM
2. **Biometric Auth** — Face ID / fingerprint unlock
3. **Data Export** — Download mood history as CSV
4. **Therapist Connect** — Optional directory for licensed professionals
5. **Breathing Exercises** — Guided animation-based relaxation tools
6. **Sentry Integration** — Error tracking and performance monitoring
