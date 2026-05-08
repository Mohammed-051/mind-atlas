#!/usr/bin/env bash
# =============================================================================
# MindMentor — Convenience Run Script
# Reads .env and launches Flutter with --dart-define flags
# =============================================================================

set -euo pipefail

if [ ! -f .env ]; then
  echo "Error: .env file not found. Run ./deploy.sh first."
  exit 1
fi

trim() {
  local value="$1"
  value="${value#${value%%[![:space:]]*}}"
  value="${value%${value##*[![:space:]]}}"
  echo "$value"
}

SUPABASE_URL=""
SUPABASE_ANON_KEY=""

while IFS= read -r line || [ -n "$line" ]; do
  line="$(trim "$line")"
  if [[ -z "$line" || "$line" == \#* ]]; then
    continue
  fi
  key="${line%%=*}"
  value="${line#*=}"
  key="$(trim "$key")"
  value="$(trim "$value")"
  value="${value%\"}"
  value="${value#\"}"

  if [[ "$key" == "SUPABASE_URL" ]]; then
    SUPABASE_URL="$value"
  elif [[ "$key" == "SUPABASE_ANON_KEY" ]]; then
    SUPABASE_ANON_KEY="$value"
  fi
done < .env

if [[ -z "$SUPABASE_URL" || -z "$SUPABASE_ANON_KEY" ]]; then
  echo "Error: SUPABASE_URL or SUPABASE_ANON_KEY not set in .env"
  exit 1
fi

echo "🧠 Starting MindMentor..."
echo "   Supabase URL: ${SUPABASE_URL}"
echo ""

flutter run \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"
