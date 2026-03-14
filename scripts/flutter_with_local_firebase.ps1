param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $repoRoot "firebase.local.json"
$flutterPath = Join-Path $env:USERPROFILE "develop\flutter\bin\flutter.bat"

if (-not (Test-Path $configPath)) {
    throw "Missing firebase.local.json. Copy firebase.local.example.json to firebase.local.json and fill in your local Firebase values."
}

if (-not (Test-Path $flutterPath)) {
    throw "Flutter was not found at $flutterPath."
}

$config = Get-Content $configPath -Raw | ConvertFrom-Json -AsHashtable

$defineOrder = @(
    "FIREBASE_PROJECT_ID",
    "FIREBASE_MESSAGING_SENDER_ID",
    "FIREBASE_STORAGE_BUCKET",
    "FIREBASE_WEB_CLIENT_ID",
    "FIREBASE_ANDROID_API_KEY",
    "FIREBASE_ANDROID_APP_ID",
    "FIREBASE_IOS_API_KEY",
    "FIREBASE_IOS_APP_ID",
    "FIREBASE_IOS_CLIENT_ID",
    "FIREBASE_IOS_BUNDLE_ID"
)

$commandArgs = New-Object System.Collections.Generic.List[string]
if ($FlutterArgs.Count -eq 0) {
    $commandArgs.AddRange(@("run", "-d", "emulator-5554"))
} else {
    $commandArgs.AddRange($FlutterArgs)
}

foreach ($key in $defineOrder) {
    if (-not $config.ContainsKey($key)) {
        continue
    }

    $value = [string]$config[$key]
    if ([string]::IsNullOrWhiteSpace($value)) {
        continue
    }

    $commandArgs.Add("--dart-define")
    $commandArgs.Add("${key}=${value}")
}

Write-Host "Running flutter with local Firebase defines from firebase.local.json"
Write-Host ""
Write-Host "$flutterPath $($commandArgs -join ' ')"
Write-Host ""

& $flutterPath @commandArgs
exit $LASTEXITCODE
