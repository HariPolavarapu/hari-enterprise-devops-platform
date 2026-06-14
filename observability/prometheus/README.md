# Prometheus

Prometheus is the metrics collection and monitoring backbone of the observability stack. It pulls time-series metrics from configured targets at regular intervals, stores them locally, and exposes a query API consumed by Grafana for visualisation.

## Role in the Observability Stack

- **Metrics Store** — Receives and persists time-series data (counters, gauges, histograms, summaries) scraped from instrumented services.
- **Grafana Data Source** — Serves the Prometheus Query API (`/api/v1/*`) to Grafana for dashboard rendering.
- **Alerting Foundation** — Alerting rules (not included in this repository) evaluate against the same TSDB and can route notifications through Alertmanager.

## Configuration

The scrape configuration is defined in `prometheus/prometheus.yml` and mounted into the container at `/etc/prometheus/prometheus.yml`.

### Global Settings

| Setting               | Value  | Description                                      |
|-----------------------|--------|--------------------------------------------------|
| `scrape_interval`     | 15s    | How often to pull metrics from each target       |
| `evaluation_interval` | 15s    | How often to evaluate alerting / recording rules |

### Scrape Jobs

| Job Name              | Target                | Metrics Endpoint                        | Description                                  |
|-----------------------|-----------------------|-----------------------------------------|----------------------------------------------|
| `prometheus`          | `prometheus:9090`     | `/metrics` (default)                    | Prometheus self-monitoring                   |
| `employee-service`    | `employee-service:8080` | `/api/actuator/prometheus`            | Spring Boot actuator-prometheus endpoint     |
| `notification-service`| `notification-service:8000` | `/metrics` (default)                | Python/FastAPI service metrics               |
| `payroll-service`     | `payroll-service:8080` | `/metrics` (default)                   | Java/Spring service metrics                  |

## Storage

- **Retention period**: 15 days (`--storage.tsdb.retention.time=15d`)
- **Storage location**: Docker named volume `prometheus-data` mounted at `/prometheus`
- **Image version**: `prom/prometheus:v2.55.0`

## Ports and Endpoints

| Port  | Endpoint            | Purpose                          |
|-------|---------------------|----------------------------------|
| 9090  | `http://localhost:9090` | Prometheus web UI and API     |

Prometheus API base URL for Grafana datasource: `http://prometheus:9090`

## Data Flow

```
Service (e.g. employee-service)              Grafana
    |                                           ^
    |  /api/actuator/prometheus                 |  /api/v1/query
    v                                           |
[Prometheus] <----------------------------------+
    |  scrape_interval = 15s
    |
    +--> TSDB (local volume, 15d retention)
```

## Local Access

Start the full observability stack:

```bash
cd observability
cp .env.example .env   # fill in credentials
docker compose up -d

# Prometheus UI
open http://localhost:9090

# Check runtime configuration
docker compose exec prometheus promtool check config /etc/prometheus/prometheus.yml
```

## Integration Points

- **Grafana** — Prometheus is provisioned as the default data source in Grafana via `grafana/provisioning/datasources/datasources.yaml`.
- **Tempo** — Tempo is configured as a separate data source in Grafana for distributed trace correlation with metrics.
- **Alertmanager** — Not included in this compose file; production deployments route alerts by adding a Prometheus `alerting` block and an Alertmanager service.

## Health Checks

```bash
# Prometheus readiness
curl -s http://localhost:9090/-/healthy

# Prometheus liveness
curl -s http://localhost:9090/-/ready
```

## Adding a New Scrape Target

Add a new entry under `scrape_configs` in `prometheus/prometheus.yml`:

```yaml
- job_name: my-service
  static_configs:
    - targets: ["my-service:8080"]
```

Reload the configuration without restarting the container:

```bash
docker compose exec prometheus promtool reload /etc/prometheus/prometheus.yml
```

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu