$ErrorActionPreference = 'Stop'

Write-Host "Stopping Docker Desktop and WSL..." -ForegroundColor Yellow
try {
  # Best-effort stop Docker Desktop
  Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
} catch {}

wsl --shutdown

Write-Host "Starting Docker Desktop..." -ForegroundColor Yellow
Start-Process "C:\\Program Files\\Docker\\Docker\\Docker Desktop.exe"

Write-Host "Waiting for Docker engine to become available..." -ForegroundColor Yellow
$maxWait = 120
$elapsed = 0
while ($true) {
  try {
    docker version | Out-Null
    break
  } catch {
    Start-Sleep -Seconds 3
    $elapsed += 3
    if ($elapsed -ge $maxWait) {
      throw "Docker engine did not become ready within $maxWait seconds."
    }
  }
}

Write-Host "Docker is up. Rebuilding and starting services..." -ForegroundColor Green
Push-Location "$PSScriptRoot/.."

docker compose down -v
docker builder prune -f
docker compose build --no-cache
docker compose up -d
docker compose ps

Write-Host "Testing endpoints..." -ForegroundColor Green
try { curl.exe http://localhost:8000/ } catch {}
try { curl.exe http://localhost:8080/ } catch {}
try { curl.exe http://localhost:8000/metrics } catch {}

Pop-Location

Write-Host "If services are not running, run: docker compose logs backend --tail=200" -ForegroundColor Yellow


