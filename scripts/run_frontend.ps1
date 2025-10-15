$ErrorActionPreference = 'Stop'

Push-Location "$PSScriptRoot/../frontend"

Write-Host "Serving frontend on http://localhost:8080 ... (Ctrl+C to stop)" -ForegroundColor Green
python -m http.server 8080

Pop-Location


