# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Project Overview

**Kube-News** is a Node.js news portal application designed to demonstrate containerization and Kubernetes best practices. It's a complete educational project for the "Imersão Claude Code DevOps" course.

### Core Technologies
- **Backend**: Node.js (v18) + Express.js
- **Frontend**: EJS templates
- **Database**: PostgreSQL 15 (Sequelize ORM)
- **Monitoring**: Prometheus + Grafana (via express-prom-bundle)
- **Deployment**: Docker + Kubernetes (DigitalOcean)

---

## Architecture

### Application Flow

```
Client Browser
    ↓
Express Server (port 8080)
    ├─→ Health/Ready endpoints (/health, /ready)
    ├─→ Metrics endpoint (/metrics)
    ├─→ Web UI Routes (/, /post, /post/:id)
    └─→ API Routes (/api/post)
        ↓
    PostgreSQL (port 5432)
        ↓
    Sequelize ORM
        ↓
    Post model (title, summary, content, publishDate)
```

### Directory Structure

```
claude-code-devops/
├── src/                          # Node.js application
│   ├── server.js                 # Express app setup + main routes
│   ├── system-life.js            # Health/ready endpoints + chaos engineering
│   ├── middleware.js             # Prometheus metrics collection
│   ├── models/
│   │   └── post.js               # Sequelize Post model + DB connection
│   ├── views/                    # EJS templates
│   │   ├── index.ejs             # Homepage (list posts)
│   │   ├── edit-news.ejs         # Create/edit post form
│   │   └── view-news.ejs         # Single post view
│   ├── static/                   # CSS, JS, images
│   └── package.json              # npm dependencies
├── Dockerfile                     # Container image definition
├── docker-compose.yml             # Local dev environment
├── k8s-bo/                       # Kubernetes manifests (old)
│   ├── postgres-*.yml            # PostgreSQL deployment
│   └── app-*.yml                 # Kube-News deployment
├── monitoring-stack.yaml          # Prometheus + Grafana stack
├── monitoring-access.sh           # Local port-forward setup
├── MONITORING_GUIDE.md            # How to use monitoring
├── POSTMORTEM.md                  # Incident analysis (important!)
└── README.md                      # User-facing documentation
```

### Kubernetes Namespace Strategy

- **default/kube-news** (old): Initial deployment (deprecated - had issues)
- **kube-news** (current): Clean namespace for application workloads
- **monitoring**: Prometheus + Grafana stack (shared)

---

## Quick Start

### Local Development

```bash
# 1. Install dependencies
cd src
npm install

# 2. Start PostgreSQL (requires Docker)
cd ..
docker-compose up postgres

# 3. In another terminal, start the app
cd src
npm start

# App runs on http://localhost:8080
# Metrics available on http://localhost:8080/metrics
```

### Local Development with Docker Compose

```bash
# Start both app and PostgreSQL
docker-compose up

# Populate sample data
curl -X POST http://localhost:8080/api/post \
  -H "Content-Type: application/json" \
  -d @popula-dados.http
```

### Deploy to Kubernetes

```bash
# Ensure MCP Kubernetes is configured in .mcp.json

# Apply monitoring stack
kubectl apply -f monitoring-stack.yaml

# Access monitoring locally
bash monitoring-access.sh
# Then visit http://localhost:3000 (Grafana) and http://localhost:9090 (Prometheus)
```

---

## Environment Variables

All env vars have defaults (suitable for Docker Compose):

| Variable | Default | Description |
|----------|---------|-------------|
| DB_DATABASE | kubedevnews | PostgreSQL database name |
| DB_USERNAME | kubedevnews | PostgreSQL user |
| DB_PASSWORD | Pg#123 | PostgreSQL password ⚠️ Change in production |
| DB_HOST | localhost | PostgreSQL host |
| DB_PORT | 5432 | PostgreSQL port |
| DB_SSL_REQUIRE | false | Require SSL for DB connection |

In Kubernetes, these come from `postgres-secret` (k8s-bo/postgres-secret.yml).

---

## Application Endpoints

### Web UI
- `GET /` — Homepage (list all news)
- `GET /post` — Create news form
- `POST /post` — Submit new news (form data)
- `GET /post/:id` — View single news item

### API
- `POST /api/post` — Bulk insert news (JSON array)
  ```json
  {
    "artigos": [
      {"title": "...", "resumo": "...", "description": "..."}
    ]
  }
  ```

### Health & Monitoring
- `GET /health` — App status (returns JSON: `{state: "up", machine: hostname}`)
- `GET /ready` — Readiness probe (returns 200 or 500)
- `GET /metrics` — Prometheus metrics (Prometheus scrapes this)

### Chaos Engineering (for testing resilience)
- `PUT /unhealth` — Make app unhealthy (all responses → 500)
- `PUT /unreadyfor/:seconds` — Simulate downtime for N seconds

---

## Monitoring Stack

A complete Prometheus + Grafana monitoring stack is deployed in the `monitoring` namespace.

### Setup
```bash
# Already deployed via monitoring-stack.yaml
# Access locally:
bash monitoring-access.sh
```

### Access URLs
- **Prometheus**: http://localhost:9090 (metrics DB, queries, alerting)
- **Grafana**: http://localhost:3000 (dashboards, username: `admin`, password: `admin`)

### Prometheus Scrape Jobs
- `prometheus` — Prometheus self-metrics
- `kubernetes-apiservers` — Kubernetes API
- `kubernetes-nodes` — Node metrics
- `kubernetes-pods` — Pod metrics (all namespaces)
- `kube-news-apps` — kube-news namespace only

### Adding Metrics to Your Apps
For apps in the `kube-news` namespace to be auto-scraped, add these Pod annotations:
```yaml
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8080"         # Your app's metrics port
  prometheus.io/path: "/metrics"     # Endpoint exposing metrics
```

---

## Known Issues & Lessons Learned

### 🔴 CRITICAL: Block Storage Volume Initialization (POSTMORTEM.md)

**Issue**: PostgreSQL fails to initialize when mounted directly on DigitalOcean Block Storage root because of the `lost+found` directory.

**Root Cause**: Block Storage automatically creates `lost+found` at mount point root. PostgreSQL's `initdb` refuses to use a non-empty directory.

**Resolution Applied**:
1. Use `subPath: pgdata` in volumeMount (separate subdirectory)
2. Set `PGDATA=/var/lib/postgresql/data/pgdata` env var
3. Add `initContainer` to clean/fix permissions before pod starts

**Why This Matters**: The old k8s-bo/ manifests don't have these fixes. Always use the monitoring-stack.yaml pattern or include the `initContainer` when working with PVCs.

### Race Condition: Secret Creation Timing
Kubernetes resources are created asynchronously. Deployment references `postgres-secret`, but Secret might not exist yet. Solution: Use kubectl apply with all resources in correct order (Secret before Deployment).

---

## Development Tasks

### Add a New News Field
1. Edit `src/models/post.js` — add to `Post.init()` sequelize model definition
2. Edit `src/views/edit-news.ejs` — add form input
3. Edit `src/views/view-news.ejs` — display the field
4. Edit `src/server.js` — handle in POST /post route

Example: Adding an `author` field
```javascript
// post.js
author: {
  type: sequelize.DataTypes.STRING,
  require: false
}

// server.js (in POST /post handler)
await models.Post.create({
  title: req.body.title,
  content: req.body.description,
  summary: req.body.resumo,
  author: req.body.author,      // ← New
  publishDate: Date.now()
});
```

### Change Database Credentials
1. Update `DB_*` env vars in `docker-compose.yml` or Kubernetes Secret
2. Update default values in `src/models/post.js` (for local dev)
3. If in Kubernetes, update `k8s-bo/postgres-secret.yml`

### Test Liveness/Readiness
```bash
# Make app unhealthy
curl -X PUT http://localhost:8080/unhealth

# Simulate 30s of unavailability
curl -X PUT http://localhost:8080/unreadyfor/30

# Verify with health checks
curl http://localhost:8080/health
curl http://localhost:8080/ready
```

### Verify Prometheus Scraping
1. Open Prometheus: http://localhost:9090
2. Go to **Status → Targets**
3. Look for job `kube-news-apps` (should show state: UP)
4. Run a query: `up{job="kube-news-apps"}` should return 1

### Build & Push Docker Image
```bash
# Build
docker build -t your-registry/kube-news:v2 .

# Push
docker push your-registry/kube-news:v2

# Update image in k8s-bo/app-deployment.yml
```

---

## Git & GitHub Workflow

### Sync with Fabricio's Upstream
```bash
# Add upstream if not already done
git remote add upstream https://github.com/veronez-io/claude-code-devops

# Fetch and merge new commits
git fetch upstream
git merge upstream/main

# Push to your fork
git push origin main
```

---

## MCP Kubernetes Integration

The `.mcp.json` file configures a Kubernetes MCP Server (Docker-based):
```json
{
  "mcpServers": {
    "kubernetes": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-v", "C:\\Users\\Remakker\\.kube\\config:/home/appuser/.kube/config:ro",
        "mcp/kubernetes"
      ]
    }
  }
}
```

This allows Claude to run `kubectl` commands via MCP. Use it for querying cluster state, deploying changes, or troubleshooting.

### Common MCP Kubernetes Commands
```bash
kubectl get pods -n kube-news
kubectl logs -n kube-news -l app=kube-news
kubectl describe pod -n kube-news <pod-name>
kubectl apply -f monitoring-stack.yaml
kubectl port-forward -n monitoring svc/grafana 3000:3000
```

---

## User Preferences

- **Language**: English for Claude (user asks follow-up questions in Portuguese if needed)
- **Shell**: Bash preferred (even on Windows)
- **Approach**: Direct, concise responses; no unnecessary explanations

---

## Resources

- **README.md** — User-facing project documentation
- **POSTMORTEM.md** — Detailed incident analysis (learn from this!)
- **MONITORING_GUIDE.md** — How to use Prometheus + Grafana
- **monitoring-stack.yaml** — Complete monitoring deployment
- **popula-dados.http** — Sample data for testing (bulk insert)

---

## Typical Workflow for Claude

1. **Diagnose**: Use MCP Kubernetes to check pod/node status
2. **Investigate**: Read logs, describe resources, check metrics
3. **Fix**: Modify manifests (k8s-bo/) or application code (src/)
4. **Deploy**: Apply changes to cluster
5. **Verify**: Check Prometheus metrics and health endpoints
6. **Document**: Update this file or incident logs if needed

---

Last updated: 2026-05-17  
Cluster: DigitalOcean Kubernetes (nyc1 region)  
Monitoring: Prometheus v2.45.0 | Grafana v10.2.0
