# =============================================================================
# MindMentor — Convenience Run Script (PowerShell)
# Reads .env and launches Flutter with --dart-define flags
# =============================================================================

$ErrorActionPreference = "Stop"

if (-not (Test-Path ".env")) {
    Write-Host "Error: .env file not found. Run .\deploy.ps1 first." -ForegroundColor Red
    exit 1
}

# Parse .env file
$envVars = @{}
Get-Content ".env" | ForEach-Object {
    $line = $_.Trim()
    if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith('#')) {
        return
    }
    if ($line -match '^(?<key>[^=]+)=(?<value>.*)$') {
        $key = $matches['key'].Trim()
        $value = $matches['value'].Trim()
        if ($value.StartsWith('"') -and $value.EndsWith('"')) {
            $value = $value.Trim('"')
        }
        $envVars[$key] = $value
    }
}

$supabaseUrl = $envVars["SUPABASE_URL"]
$supabaseAnonKey = $envVars["SUPABASE_ANON_KEY"]

if ([string]::IsNullOrWhiteSpace($supabaseUrl) -or [string]::IsNullOrWhiteSpace($supabaseAnonKey)) {
    Write-Host "Error: SUPABASE_URL or SUPABASE_ANON_KEY not set in .env" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "  Starting MindMentor..." -ForegroundColor Cyan
Write-Host "  Supabase URL: $supabaseUrl" -ForegroundColor Gray
Write-Host ""

flutter run `
    --dart-define="SUPABASE_URL=$supabaseUrl" `
    --dart-define="SUPABASE_ANON_KEY=$supabaseAnonKey"
