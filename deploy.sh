#!/usr/bin/env bash
# =============================================================================
# MindMentor — Automated Deployment Script
# =============================================================================
# Usage:
#   chmod +x deploy.sh
#   ./deploy.sh
#
# Prerequisites:
#   - Supabase CLI installed (https://supabase.com/docs/guides/cli)
#   - A Supabase project created at https://supabase.com/dashboard
#   - An OpenRouter API key from https://openrouter.ai/keys
#   - Flutter SDK installed
# =============================================================================

set -euo pipefail

# ── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Helpers ─────────────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}ℹ ${RESET}${1}"; }
success() { echo -e "${GREEN}✓ ${RESET}${1}"; }
warn()    { echo -e "${YELLOW}⚠ ${RESET}${1}"; }
error()   { echo -e "${RED}✗ ${RESET}${1}"; exit 1; }
header()  { echo -e "\n${MAGENTA}${BOLD}═══ ${1} ═══${RESET}\n"; }
prompt()  { echo -en "${CYAN}→ ${RESET}${1}: "; }

# ── Banner ──────────────────────────────────────────────────────────────────
echo -e "${BOLD}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║          🧠  MindMentor Deploy           ║"
echo "  ║     AI-Powered Mental Well-Being App     ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${RESET}"

# ── Step 0: Prerequisite Checks ────────────────────────────────────────────
header "Checking Prerequisites"

command -v supabase >/dev/null 2>&1 || error "Supabase CLI not found. Install: https://supabase.com/docs/guides/cli"
success "Supabase CLI found: $(supabase --version 2>/dev/null || echo 'installed')"

command -v flutter >/dev/null 2>&1 || error "Flutter SDK not found. Install: https://docs.flutter.dev/get-started/install"
success "Flutter SDK found: $(flutter --version 2>/dev/null | head -1)"

# ── Step 1: Collect Credentials ────────────────────────────────────────────
header "Step 1 — Supabase Project Credentials"

info "Find these in your Supabase Dashboard:"
info "  → Project Settings → General → Reference ID"
info "  → Project Settings → API → Project URL"
info "  → Project Settings → API → anon public key"
echo ""

prompt "Supabase Project Reference ID"
read -r PROJECT_REF
[ -z "$PROJECT_REF" ] && error "Project Reference ID is required"

prompt "Supabase Project URL (https://xxxxx.supabase.co)"
read -r SUPABASE_URL
[ -z "$SUPABASE_URL" ] && error "Supabase URL is required"

prompt "Supabase Anon Key"
read -r SUPABASE_ANON_KEY
[ -z "$SUPABASE_ANON_KEY" ] && error "Supabase Anon Key is required"

prompt "OpenRouter API Key (sk-or-...)"
read -r OPENROUTER_API_KEY
[ -z "$OPENROUTER_API_KEY" ] && error "OpenRouter API Key is required"

# ── Step 2: Link Supabase Project ──────────────────────────────────────────
header "Step 2 — Linking to Supabase Project"

info "Linking local project to: ${PROJECT_REF}"
supabase link --project-ref "$PROJECT_REF"
success "Project linked successfully"

# ── Step 3: Push Database Schema ───────────────────────────────────────────
header "Step 3 — Pushing Database Schema"

info "Applying migration: 20260508000000_init_schema.sql"
info "This creates: profiles, mood_logs, chat_sessions, messages (all with RLS)"
supabase db push
success "Database schema deployed with RLS policies"

# ── Step 4: Set Edge Function Secrets ──────────────────────────────────────
header "Step 4 — Setting Edge Function Secrets"

info "Setting OPENROUTER_API_KEY as a Supabase secret..."
supabase secrets set "OPENROUTER_API_KEY=${OPENROUTER_API_KEY}"
success "OpenRouter API key stored securely"

# ── Step 5: Deploy Edge Function ───────────────────────────────────────────
header "Step 5 — Deploying AI Proxy Edge Function"

info "Deploying ai_proxy function..."
supabase functions deploy ai_proxy --no-verify-jwt
success "Edge Function 'ai_proxy' deployed"
info "JWT verification is handled in-code for better error messages"

# ── Step 6: Save .env for Flutter ──────────────────────────────────────────
header "Step 6 — Generating Flutter .env"

cat > .env <<EOF
SUPABASE_URL=${SUPABASE_URL}
SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
EOF
success "Created .env file (gitignored)"

# ── Done ────────────────────────────────────────────────────────────────────
header "🎉 Deployment Complete!"

echo -e "${GREEN}${BOLD}All systems are go!${RESET}\n"
echo -e "Run the Flutter app with:"
echo -e "  ${CYAN}flutter run \\${RESET}"
echo -e "  ${CYAN}  --dart-define=SUPABASE_URL=${SUPABASE_URL} \\${RESET}"
echo -e "  ${CYAN}  --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}${RESET}"
echo ""
echo -e "Or use the convenience script:"
echo -e "  ${CYAN}./run.sh${RESET}"
echo ""
info "Edge Function URL: ${SUPABASE_URL}/functions/v1/ai_proxy"
info "Dashboard: https://supabase.com/dashboard/project/${PROJECT_REF}"
echo ""
