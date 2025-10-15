## Standard Operating Procedure (SOP) – Fusionpact DevOps Challenge

This SOP documents the full set of steps and exact commands executed to complete, verify, and deliver the solution. It includes local run options, Docker/WSL fixes, CI pipeline usage, and Git commands used to push to GitHub.

### 1) Repository Preparation

Commands executed in PowerShell from the project root unless stated otherwise.

```powershell
# Initialize local git repo and set identity (local only)
git init
git config user.name "DevOps Bot"
git config user.email devnull@example.com
git branch -M main

# First commit of all solution files
git add -A
git commit -m "DevOps challenge: docker, compose, CI, k8s, monitoring, docs"

# Add fork as remote and push
git remote add origin https://github.com/Mudabbirarafat/fusionpact-devops-challenge
git push -u origin main  # initially rejected because remote had changes

# Create a feature branch containing the solution and push it
git checkout -b devops-solution
git push -u origin devops-solution

# Merge solution into main with conflict resolution (docker-compose.yml)
git checkout main
git pull --rebase origin main
git checkout --ours docker-compose.yml
git add docker-compose.yml
git commit -m "Resolve docker-compose conflict; integrate DevOps solution"
git rebase --continue
git push origin main
```

Notes:
- If your remote fork URL differs, replace it accordingly.
- Authentication via browser or PAT may be prompted by Git.

### 2) Containerization & Orchestration Files Added

Key files added/edited:
- `backend/Dockerfile`
- `frontend/Dockerfile`
- `docker-compose.yml`
- `monitoring/prometheus/prometheus.yml`
- `monitoring/grafana/datasources/datasource.yml`
- `monitoring/grafana/dashboards/dashboard.yml`
- `monitoring/grafana/dashboards_json/FastAPI_Metrics.json`
- `k8s/backend-deployment.yaml`, `k8s/frontend-deployment.yaml`, `k8s/monitoring.yaml`
- `DEVOPS_SOLUTION.md` (how-to and verification)
- `scripts/run_backend.ps1`, `scripts/run_frontend.ps1`, `scripts/fix_docker_wsl.ps1`
- `.github/workflows/ci.yml` (CI pipeline)

### 3) Local Run – Without Docker (Fallback)

Backend (FastAPI):
```powershell
./scripts/run_backend.ps1
# Verifications
curl.exe http://localhost:8000/
curl.exe http://localhost:8000/users
curl.exe http://localhost:8000/docs
curl.exe http://localhost:8000/metrics
```

Frontend (static HTML served on 8080):
```powershell
./scripts/run_frontend.ps1
# Open http://localhost:8080/
```

### 4) Docker Desktop / WSL2 Fix (Windows)

If the Docker engine API returned 500 or failed to connect, run the automated recovery script (PowerShell):
```powershell
./scripts/fix_docker_wsl.ps1
```

If WSL2 is not installed/configured yet (run PowerShell as Administrator, then reboot):
```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl --install -d Ubuntu
wsl --set-default-version 2
shutdown /r /t 0
```

After reboot, open Ubuntu once, then enable WSL integration in Docker Desktop.

### 5) Local Run – With Docker Compose

```powershell
docker compose down -v
docker compose build --no-cache
docker compose up -d
docker compose ps
```

Verify endpoints:
```powershell
curl.exe http://localhost:8000/
curl.exe http://localhost:8000/users
curl.exe http://localhost:8080/
curl.exe http://localhost:9090/ -I  # Prometheus
# Open http://localhost:3000 (Grafana admin/admin)
```

Generate some traffic for metrics:
```powershell
for /l %i in (1,1,20) do @curl.exe http://localhost:8000/ >NUL
```

### 6) CI/CD – GitHub Actions

Workflow file: `.github/workflows/ci.yml`

Triggers: push/PR to `main` or `master`.

What it does:
- Checkout
- Set up Python 3.11
- Install backend dependencies
- Sanity check imports (FastAPI, uvicorn, prometheus instrumentator)
- Build backend and frontend Docker images

No commands required locally beyond pushing to GitHub:
```powershell
git add -A
git commit -m "Update"
git push
```
Then check Actions tab in GitHub.

### 7) Kubernetes (Optional)

Apply manifests to any K8s cluster (kind/minikube/etc.):
```powershell
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/monitoring.yaml
kubectl get pods -w
```

Port-forward for access:
```powershell
kubectl port-forward svc/backend 8000:8000 &
kubectl port-forward svc/frontend 8080:80 &
kubectl port-forward svc/prometheus 9090:9090 &
kubectl port-forward svc/grafana 3000:3000 &
```

### 8) Verification Checklist (Commands)

Backend API:
```powershell
curl.exe http://localhost:8000/
curl.exe -X POST http://localhost:8000/users -H "Content-Type: application/json" -d '{"first_name":"John","last_name":"Doe","age":25}'
curl.exe http://localhost:8000/users
curl.exe http://localhost:8000/metrics
```

Frontend:
```powershell
curl.exe http://localhost:8080/
```

Prometheus:
```powershell
# Open http://localhost:9090 → Status → Targets (backend should be UP)
```

Grafana:
```powershell
# Open http://localhost:3000 (admin/admin)
# Pre-provisioned dashboard: "FastAPI Metrics"
```

### 9) Cloud Deployment (Guidance)

Push images to a registry (example commands):
```powershell
# Example tags (replace REGISTRY/REPO)
docker build -t REGISTRY/REPO/backend:latest ./backend
docker build -t REGISTRY/REPO/frontend:latest ./frontend
docker push REGISTRY/REPO/backend:latest
docker push REGISTRY/REPO/frontend:latest
```
Deploy on ECS/EKS/AKS/GKE or a VM using the same compose file; ensure inbound rules for ports 80/8000/3000/9090 as needed.

### 10) References

- Challenge repo (upstream, read-only): [FusionpactTech/fusionpact-devops-challenge](https://github.com/FusionpactTech/fusionpact-devops-challenge)
- Your fork (solution pushed): `https://github.com/Mudabbirarafat/fusionpact-devops-challenge`


