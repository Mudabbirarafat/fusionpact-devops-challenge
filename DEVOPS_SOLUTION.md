## Fusionpact DevOps Challenge – End-to-End Solution

This repository now includes containerization, local orchestration, CI workflow, optional Kubernetes manifests, and monitoring (Prometheus + Grafana).

### Contents
- Backend Dockerfile (`backend/Dockerfile`)
- Frontend Dockerfile (`frontend/Dockerfile`)
- Local multi-service orchestration (`docker-compose.yml`)
- Monitoring configs (Prometheus and Grafana) in `monitoring/`
- GitHub Actions CI workflow (`.github/workflows/ci.yml`)
- Optional Kubernetes manifests in `k8s/`

### Prerequisites
- Docker and Docker Compose
- Optional: kubectl and a Kubernetes cluster (e.g., kind, k3d, minikube)

### Quickstart (Docker Compose)
```bash
docker compose up -d --build
```

Services:
- Backend FastAPI: http://localhost:8000
- Frontend (nginx): http://localhost:8080
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/admin)

Metrics endpoint: http://localhost:8000/metrics (already instrumented)

### CI (GitHub Actions)
Workflow: `.github/workflows/ci.yml`
- Triggers on push/PR to `main`/`master`
- Installs backend deps and builds backend/frontend images

### Kubernetes (Optional)
Apply manifests in a cluster:
```bash
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/monitoring.yaml
```

Port-forward for access (example):
```bash
kubectl port-forward svc/backend 8000:8000 &
kubectl port-forward svc/frontend 8080:80 &
kubectl port-forward svc/prometheus 9090:9090 &
kubectl port-forward svc/grafana 3000:3000 &
```

### Verification Steps
- Hit backend root: `curl http://localhost:8000/`
- Create user: `curl -X POST http://localhost:8000/users -H 'Content-Type: application/json' -d '{"first_name":"John","last_name":"Doe","age":25}'`
- List users: `curl http://localhost:8000/users`
- Check metrics: `curl http://localhost:8000/metrics`
- Prometheus targets: open Prometheus → Status → Targets (backend should be up)
- Grafana: login (admin/admin) → pre-provisioned dashboard "FastAPI Metrics"

### Notes
- `docker-compose.yml` uses named network `fusionpact` and mounts read-only configs for Prometheus and Grafana provisioning.
- Images are tagged `fusionpact/backend:latest` and `fusionpact/frontend:latest` for local and k8s reuse.

---

## Verification (Detailed)

### 1) Deployment (Docker Compose)
1. Start services:
   ```bash
   docker compose up -d --build
   docker compose ps
   ```
   Expected: all services `backend`, `frontend`, `prometheus`, `grafana` are `running`.

2. Backend health:
   ```bash
   curl -sS http://localhost:8000/
   ```
   Expected:
   ```json
   {"message":"Hello from FastAPI -@kiranrakh155@gmail.com ;)"}
   ```

3. Create and list users:
   ```bash
   curl -sS -X POST http://localhost:8000/users \
     -H 'Content-Type: application/json' \
     -d '{"first_name":"John","last_name":"Doe","age":25}'
   # => {"success": true}

   curl -sS http://localhost:8000/users
   # => {"data":[{"first_name":"John","last_name":"Doe","age":25}]}
   ```

4. Frontend page:
   - Open `http://localhost:8080` in a browser. Expected: internship landing page loads via nginx.

### 2) CI/CD (GitHub Actions)
1. Push to your fork (main/master or open PR):
   ```bash
   git add -A
   git commit -m "DevOps challenge solution"
   git push origin <branch>
   ```
2. In your GitHub repo → Actions tab:
   - Workflow `CI` should run and complete green.
   - It installs backend deps and builds backend/frontend images.

### 3) Monitoring (Prometheus + Grafana)
1. Prometheus targets:
   - Open `http://localhost:9090` → Status → Targets.
   - Expected: job `backend` target `backend:8000` is `UP`.

2. Query metrics:
   - In Prometheus, run query: `sum(increase(http_requests_total[5m]))`.
   - Expected: a non-empty time series after hitting the backend.

3. Grafana dashboard:
   - Open `http://localhost:3000` (admin/admin).
   - A `Prometheus` datasource is pre-provisioned.
   - Dashboard "FastAPI Metrics" is provisioned and shows request rate and p95 latency once traffic is generated.

### 4) Kubernetes (Optional)
1. Apply manifests:
   ```bash
   kubectl apply -f k8s/backend-deployment.yaml
   kubectl apply -f k8s/frontend-deployment.yaml
   kubectl apply -f k8s/monitoring.yaml
   kubectl get pods -w
   ```
   Expected: pods for backend, frontend, prometheus, grafana become `Running`.

2. Port-forward to verify:
   ```bash
   kubectl port-forward svc/backend 8000:8000 &
   kubectl port-forward svc/frontend 8080:80 &
   kubectl port-forward svc/prometheus 9090:9090 &
   kubectl port-forward svc/grafana 3000:3000 &
   ```
   Then repeat the checks from sections 1), 3).


