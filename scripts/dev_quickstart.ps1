param(
  [string]$Device = "windows"  # Accepts "windows", "chrome", or any Flutter device id
)

$ErrorActionPreference = "Stop"

function Write-Info($msg) { Write-Host "[EcoView] $msg" -ForegroundColor Cyan }
function Write-Warn($msg) { Write-Host "[EcoView] $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "[EcoView] $msg" -ForegroundColor Red }

# Resolve repo root from script location
$RepoRoot = (Resolve-Path -Path (Join-Path $PSScriptRoot "..")).Path
$Backend  = Join-Path $RepoRoot "python_backend"
$Frontend = Join-Path $RepoRoot "flutter_frontend"

Write-Info "Repo root: $RepoRoot"

# 1) Backend: create venv and install deps
Write-Info "Setting up Python backend virtual environment..."
if (!(Test-Path (Join-Path $Backend ".venv"))) {
  Write-Info "Creating venv in python_backend/.venv"
  Push-Location $Backend
  python -m venv .venv
  Pop-Location
}

Write-Info "Installing backend requirements..."
Push-Location $Backend
. .\.venv\Scripts\Activate.ps1
pip install --upgrade pip > $null
pip install -r requirements.txt

# Start backend in new window if not already started
Write-Info "Starting Flask backend on http://0.0.0.0:5000 ..."
$backendCmd = "`"cd `"$Backend`"; .\.venv\Scripts\Activate.ps1; python app.py`""
Start-Process powershell -ArgumentList "-NoExit", "-Command", $backendCmd | Out-Null
Pop-Location

Start-Sleep -Seconds 3

# 2) Frontend: ensure flutter available
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Err "Flutter is not available in PATH. Please install Flutter and re-open PowerShell."
  exit 1
}

Write-Info "Preparing Flutter frontend..."
Push-Location $Frontend
flutter pub get

# If the selected device isn't available, fallback to chrome
$devicesText = flutter devices | Out-String
if ($Device -eq "windows" -and ($devicesText -notmatch "Windows\s+.*\(desktop\)")) {
  Write-Warn "Windows desktop device not available. Falling back to Chrome."
  $Device = "chrome"
}

Write-Info "Launching Flutter app (-d $Device)..."
flutter run -d $Device
Pop-Location
