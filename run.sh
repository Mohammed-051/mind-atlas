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

# Source the .env file
export $(grep -v '^#' .env | xargs)

echo "🧠 Starting MindMentor..."
echo "   Supabase URL: ${SUPABASE_URL}"
echo ""

flutter run \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"
