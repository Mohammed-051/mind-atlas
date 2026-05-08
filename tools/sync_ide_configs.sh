#!/usr/bin/env bash
# =============================================================================
# MindMentor — Sync IDE Run Configs (Bash)
# Reads .env and writes IDE launch configurations with --dart-define flags
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

mkdir -p .vscode
cat > .vscode/launch.json <<EOF
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "MindMentor (Debug)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "toolArgs": [
        "--dart-define=SUPABASE_URL=${SUPABASE_URL}",
        "--dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}"
      ]
    }
  ]
}
EOF

mkdir -p .idea/runConfigurations
cat > .idea/runConfigurations/MindMentor_Dev.xml <<EOF
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="MindMentor Dev" type="FlutterRunConfigurationType" factoryName="Flutter">
    <option name="additionalArgs" value="--dart-define=SUPABASE_URL=${SUPABASE_URL} --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}" />
    <option name="filePath" value="\$PROJECT_DIR\$/lib/main.dart" />
    <method v="2" />
  </configuration>
</component>
EOF

echo "Synced VS Code and IntelliJ run configs from .env"

