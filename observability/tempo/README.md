# Grafana Tempo

Tempo is the distributed tracing backend of the observability stack. It receives OpenTelemetry Protocol (OTLP) traces, stores them in a local object store, and exposes a query API consumed by Grafana.

## Role in the Observability Stack

- **Trace Storage** — Ingests and persists distributed trace data (spans, span events, links) in a cost-effective backend.
- **Grafana Data Source** — Serves the Tempo API (`/api/*`) and the Querier API (`/api/traces/*`) to Grafana for trace visualisation and flame graph rendering.
- **Correlation Engine** — Enables correlation between metrics (Prometheus) and traces (Tempo) within Grafana, supporting MQL and exemplar-based drill-down.

## Configuration

Tempo is configured via `tempo/tempo.yaml` which is mounted into the container at `/etc/tempo.yaml`.

### Key Configuration Blocks

```yaml
server:
  http_listen_port: 3200      # Tempo query-frontend HTTP API

distributor:
  receivers:
    otlp:
      protocols:
        grpc:
          endpoint: 0.0.0.0:4317   # OTLP gRPC receiver

storage:
  trace:
    backend: local
    local:
      path: /var/tempo/traces       # Trace block storage
    wal:
      path: /var/tempo/wal          # Write-ahead log for compactor

compactor:
  compaction:
    block_retention: 48h            # Trace retention before compaction
```

## Ports and Endpoints

| Port  | Protocol | Endpoint / Purpose                              |
|-------|----------|------------------------------------------------|
| 3200  | HTTP     | Tempo query API — used by Grafana datasource   |
| 4317  | gRPC     | OTLP receiver — accepts trace spans            |

Tempo does **not** expose an OTLP HTTP receiver in this configuration; only gRPC is enabled on port `4317`.

## Docker Compose Service

```yaml
tempo:
  image: grafana/tempo:2.6.1
  command: ["-config.file=/etc/tempo.yaml"]
  volumes:
    - ./tempo/tempo.yaml:/etc/tempo.yaml:ro
    - tempo-data:/var/tempo
  ports: ["3200:3200", "4317:4317"]
  restart: unless-stopped
```

Volume `tempo-data` is mounted at `/var/tempo` and persists trace blocks and WAL data across restarts.

## Data Flow

```
Instrumented Service
       |
       |  OTLP gRPC (proto)
       v
[Tempo] :4317  ──(distributor)──> [Storage: /var/tempo/traces]
                                       ^
                                       | Querier
                                       v
                              [Grafana] :3000  (Tempo datasource)
```

1. Instrumented services send spans over OTLP gRPC to `tempo:4317`.
2. Tempo's distributor forwards trace data to the ingester and write-ahead log (WAL).
3. Blocks are flushed to `/var/tempo/traces` on the named volume.
4. Grafana queries trace data via `http://tempo:3200` when exploring traces or rendering flame graphs.

## Sending Traces to Tempo

Services must be instrumented with an OpenTelemetry SDK (or OTLP exporter) and configured to export traces via gRPC to `tempo:4317`.

### Python (OpenTelemetry SDK)

```python
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

provider = TracerProvider()
processor = BatchSpanProcessor(
    OTLPSpanExporter(endpoint="http://tempo:4317", insecure=True)
)
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)
```

### Java / Spring Boot (Micrometer + OTLP)

```properties
management.otlp.tracing.endpoint=http://tempo:4317
management.otlp.tracing.endpoint-protocol=grpc
```

## Grafana Integration

Grafana is provisioned to use Tempo as a data source at `http://tempo:3200`. To explore traces:

1. Open Grafana at `http://localhost:3000`.
2. Navigate to **Explore** and select the **Tempo** data source.
3. Use **Search** to find traces by service name, or **Trace ID** to look up a specific trace.

Grafana can also correlate Prometheus metrics with Tempo traces using exemplars — Grafana will show a Tempo link in metric tooltips when trace context is attached.

## Retention

Trace blocks are retained for **48 hours** (`block_retention: 48h` in `tempo.yaml`). After compaction, older blocks are deleted. Ensure `tempo-data` volume backups or object-store replication are in place for production retention requirements beyond 48 hours.

## Local Access

```bash
cd observability
docker compose up -d tempo

# Tempo query API (used by Grafana)
curl http://localhost:3200/api/status

# List configured receivers
curl http://localhost:3200/api/v1/status/traces
```

## Health Checks

```bash
# Readiness probe
curl -s http://localhost:3200/ready

# Liveness probe
curl -s http://localhost:3200/ping
```

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu