# =============================================================================
# MindMentor — Automated Deployment Script (PowerShell)
# =============================================================================
# Usage:
#   .\deploy.ps1
#
# Prerequisites:
#   - Supabase CLI installed (https://supabase.com/docs/guides/cli)
#   - A Supabase project created at https://supabase.com/dashboard
#   - An OpenRouter API key from https://openrouter.ai/keys
#   - Flutter SDK installed
# =============================================================================

$ErrorActionPreference = "Stop"

# ── Helpers ─────────────────────────────────────────────────────────────────
function Write-Info    { param($msg) Write-Host "  i " -ForegroundColor Blue -NoNewline; Write-Host $msg }
function Write-Success { param($msg) Write-Host "  ✓ " -ForegroundColor Green -NoNewline; Write-Host $msg }
function Write-Warn    { param($msg) Write-Host "  ! " -ForegroundColor Yellow -NoNewline; Write-Host $msg }
function Write-Err     { param($msg) Write-Host "  ✗ " -ForegroundColor Red -NoNewline; Write-Host $msg; exit 1 }
function Write-Header  { param($msg) Write-Host "`n=== $msg ===" -ForegroundColor Magenta -Bold }
function Read-Value    { param($msg) Write-Host "  → " -ForegroundColor Cyan -NoNewline; return Read-Host $msg }

# ── Banner ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor White
Write-Host "  ║          🧠  MindMentor Deploy           ║" -ForegroundColor White
Write-Host "  ║     AI-Powered Mental Well-Being App     ║" -ForegroundColor White
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor White
Write-Host ""

# ── Step 0: Prerequisite Checks ────────────────────────────────────────────
Write-Header "Checking Prerequisites"

try { $null = Get-Command supabase -ErrorAction Stop; Write-Success "Supabase CLI found" }
catch { Write-Err "Supabase CLI not found. Install: https://supabase.com/docs/guides/cli" }

try { $null = Get-Command flutter -ErrorAction Stop; Write-Success "Flutter SDK found" }
catch { Write-Err "Flutter SDK not found. Install: https://docs.flutter.dev/get-started/install" }

# ── Step 1: Collect Credentials ────────────────────────────────────────────
Write-Header "Step 1 — Supabase Project Credentials"

Write-Info "Find these in your Supabase Dashboard:"
Write-Info "  → Project Settings → General → Reference ID"
Write-Info "  → Project Settings → API → Project URL"
Write-Info "  → Project Settings → API → anon public key"
Write-Host ""

$ProjectRef = Read-Value "Supabase Project Reference ID"
if ([string]::IsNullOrWhiteSpace($ProjectRef)) { Write-Err "Project Reference ID is required" }

$SupabaseUrl = Read-Value "Supabase Project URL (https://xxxxx.supabase.co)"
if ([string]::IsNullOrWhiteSpace($SupabaseUrl)) { Write-Err "Supabase URL is required" }

$SupabaseAnonKey = Read-Value "Supabase Anon Key"
if ([string]::IsNullOrWhiteSpace($SupabaseAnonKey)) { Write-Err "Supabase Anon Key is required" }

$OpenRouterKey = Read-Value "OpenRouter API Key (sk-or-...)"
if ([string]::IsNullOrWhiteSpace($OpenRouterKey)) { Write-Err "OpenRouter API Key is required" }

# ── Step 2: Link Supabase Project ──────────────────────────────────────────
Write-Header "Step 2 — Linking to Supabase Project"

Write-Info "Linking local project to: $ProjectRef"
supabase link --project-ref $ProjectRef
Write-Success "Project linked successfully"

# ── Step 3: Push Database Schema ───────────────────────────────────────────
Write-Header "Step 3 — Pushing Database Schema"

Write-Info "Applying migration: 20260508000000_init_schema.sql"
Write-Info "This creates: profiles, mood_logs, chat_sessions, messages (all with RLS)"
supabase db push
Write-Success "Database schema deployed with RLS policies"

# ── Step 4: Set Edge Function Secrets ──────────────────────────────────────
Write-Header "Step 4 — Setting Edge Function Secrets"

Write-Info "Setting OPENROUTER_API_KEY as a Supabase secret..."
supabase secrets set "OPENROUTER_API_KEY=$OpenRouterKey"
Write-Success "OpenRouter API key stored securely"

# ── Step 5: Deploy Edge Function ───────────────────────────────────────────
Write-Header "Step 5 — Deploying AI Proxy Edge Function"

Write-Info "Deploying ai_proxy function..."
supabase functions deploy ai_proxy --no-verify-jwt
Write-Success "Edge Function 'ai_proxy' deployed"
Write-Info "JWT verification is handled in-code for better error messages"

# ── Step 6: Save .env for Flutter ──────────────────────────────────────────
Write-Header "Step 6 — Generating Flutter .env"

@"
SUPABASE_URL=$SupabaseUrl
SUPABASE_ANON_KEY=$SupabaseAnonKey
"@ | Set-Content -Path ".env" -Encoding UTF8

Write-Success "Created .env file (gitignored)"

# ── Done ────────────────────────────────────────────────────────────────────
Write-Header "Deployment Complete!"

Write-Host ""
Write-Host "  All systems are go!" -ForegroundColor Green
Write-Host ""
Write-Host "  Run the Flutter app with:" -ForegroundColor White
Write-Host "    flutter run ``" -ForegroundColor Cyan
Write-Host "      --dart-define=SUPABASE_URL=$SupabaseUrl ``" -ForegroundColor Cyan
Write-Host "      --dart-define=SUPABASE_ANON_KEY=$SupabaseAnonKey" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Or use the convenience script:" -ForegroundColor White
Write-Host "    .\run.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Info "Edge Function URL: $SupabaseUrl/functions/v1/ai_proxy"
Write-Info "Dashboard: https://supabase.com/dashboard/project/$ProjectRef"
Write-Host ""
