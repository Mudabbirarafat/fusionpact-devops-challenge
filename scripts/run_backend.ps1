$ErrorActionPreference = 'Stop'

Push-Location "$PSScriptRoot/../backend"

if (-not (Test-Path .venv)) {
  python -m venv .venv
}

& .\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt

Write-Host "Starting FastAPI on http://localhost:8000 ..." -ForegroundColor Green
uvicorn app.main:app --host 0.0.0.0 --port 8000

Pop-Location


