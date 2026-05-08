# =============================================================================
# MindMentor — Sync IDE Run Configs (PowerShell)
# Reads .env and writes IDE launch configurations with --dart-define flags
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

# VS Code launch config
New-Item -ItemType Directory -Force -Path ".vscode" | Out-Null
$launchJson = @{
    version = "0.2.0"
    configurations = @(
        @{
            name = "MindMentor (Debug)"
            type = "dart"
            request = "launch"
            program = "lib/main.dart"
            toolArgs = @(
                "--dart-define=SUPABASE_URL=$supabaseUrl",
                "--dart-define=SUPABASE_ANON_KEY=$supabaseAnonKey"
            )
        }
    )
} | ConvertTo-Json -Depth 6

Set-Content -Path ".vscode/launch.json" -Value $launchJson -Encoding UTF8

# IntelliJ run configuration
New-Item -ItemType Directory -Force -Path ".idea/runConfigurations" | Out-Null
$xml = @"
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="MindMentor Dev" type="FlutterRunConfigurationType" factoryName="Flutter">
    <option name="additionalArgs" value="--dart-define=SUPABASE_URL=$supabaseUrl --dart-define=SUPABASE_ANON_KEY=$supabaseAnonKey" />
    <option name="filePath" value="$PROJECT_DIR$/lib/main.dart" />
    <method v="2" />
  </configuration>
</component>
"@

Set-Content -Path ".idea/runConfigurations/MindMentor_Dev.xml" -Value $xml -Encoding UTF8

Write-Host "Synced VS Code and IntelliJ run configs from .env" -ForegroundColor Green

