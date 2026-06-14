# Grafana

Grafana is the visualisation and analytics layer of the observability stack. It connects to Prometheus for metrics and Tempo for distributed traces, providing dashboards, exploration tools, and alerting capabilities.

## Role in the Observability Stack

- **Metrics Visualisation** — Queries Prometheus via the data source API and renders time-series graphs, stat panels, and tables.
- **Trace Visualisation** — Connects to Tempo to explore distributed trace flame graphs and span-level detail.
- **Unified Observability** — Correlates metrics and traces within the same UI, enabling rapid root-cause analysis across the stack.

## Provisioned Configuration

Grafana is provisioned automatically at startup using configuration files mounted from `grafana/provisioning/`. No manual data source or dashboard configuration is required for first-run.

### Data Sources

Defined in `grafana/provisioning/datasources/datasources.yaml`:

| Name      | Type     | URL                    | Default | Description                        |
|-----------|----------|------------------------|---------|------------------------------------|
| Prometheus| Prometheus | `http://prometheus:9090` | Yes    | Metrics engine                     |
| Tempo     | Tempo    | `http://tempo:3200`      | No     | Distributed tracing backend        |

Credentials for secured data sources are supplied at runtime via environment variables — **no secrets are stored in Git**.

### Dashboards

Defined in `grafana/provisioning/dashboards/dashboards.yaml`:

| Provider    | Folder             | Type | Path                             |
|-------------|--------------------|------|----------------------------------|
| `platform`  | Enterprise Platform| file | `/var/lib/grafana/dashboards`    |

Drop `.json` dashboard files into `grafana/provisioning/dashboards/` (or a mounted equivalent) to have them auto-loaded into the **Enterprise Platform** folder.

## Environment Variables

| Variable                    | Purpose                              |
|-----------------------------|--------------------------------------|
| `GF_SECURITY_ADMIN_USER`    | Grafana admin login username         |
| `GF_SECURITY_ADMIN_PASSWORD`| Grafana admin password               |

Set these in the `.env` file (copy from `.env.example`). The default `admin` credentials are **not** used; values are injected at container startup.

## Ports and Endpoints

| Port | Endpoint             | Purpose                        |
|------|----------------------|--------------------------------|
| 3000 | `http://localhost:3000` | Grafana web UI and API      |

Default login: credentials from `GRAFANA_ADMIN_USER` / `GRAFANA_ADMIN_PASSWORD` in `.env`.

## Docker Compose Service

```yaml
grafana:
  image: grafana/grafana:11.2.0
  ports: ["3000:3000"]
  environment:
    GF_SECURITY_ADMIN_USER: ${GRAFANA_ADMIN_USER}
    GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_ADMIN_PASSWORD}
  volumes:
    - ./grafana/provisioning:/etc/grafana/provisioning:ro
    - grafana-data:/var/lib/grafana
  restart: unless-stopped
```

## Local Access

```bash
cd observability
cp .env.example .env   # set GRAFANA_ADMIN_USER / GRAFANA_ADMIN_PASSWORD
docker compose up -d grafana

open http://localhost:3000
```

## Data Flow

```
Prometheus ──(metrics)──> Grafana ──(visualise)──> Browser
Tempo ───────(traces)───>            (flame graphs, spans)
```

## Adding Custom Dashboards

1. Create or export a dashboard JSON from the Grafana UI.
2. Place it in `grafana/provisioning/dashboards/` (ensure the file is mounted into the container).
3. Restart the container: `docker compose restart grafana`

## Admin API

Grafana exposes an admin API at `http://localhost:3000/api`. Use the admin credentials for programmatic datasource or dashboard management.

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu