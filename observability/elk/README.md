# ELK Stack

The ELK Stack provides log aggregation, parsing, indexing, and search capabilities for the observability platform. It consists of Elasticsearch (storage/search), Logstash (ingest pipeline), and Kibana (visualisation UI).

## Role in the Observability Stack

- **Centralised Log Sink** — Receives structured and unstructured logs from services, system components, and Beats agents via the Beats protocol.
- **Search and Analytics** — Elasticsearch powers full-text search, field filtering, and aggregations over log events.
- **Log Visualisation** — Kibana provides Discover, Dashboard, and Lens interfaces for exploring indexed log data.

## Architecture

```
Beats / Shipping Agents
         |
         |  Beats protocol (TLS optional)
         v
[Logstash] :5044  ──(parse/filter)──> [Elasticsearch] :9200  <──> [Kibana] :5601
              input                    storage & search              UI
```

## Components

### Elasticsearch

| Property          | Value                                  |
|-------------------|----------------------------------------|
| Image             | `docker.elastic.co/elasticsearch/elasticsearch:8.15.2` |
| Port              | `9200`                                 |
| Security          | TLS + basic auth enabled (`xpack.security.enabled: true`) |
| Auth              | Built-in `elastic` user + `ELASTIC_PASSWORD` |
| Discovery         | Single-node (`discovery.type: single-node`) |
| Data volume       | `elasticsearch-data` at `/usr/share/elasticsearch/data` |

**API base URL**: `http://localhost:9200`

### Logstash

| Property   | Value                                              |
|------------|----------------------------------------------------|
| Image      | `docker.elastic.co/logstash/logstash:8.15.2`       |
| Port       | `5044` (Beats input)                               |
| Config     | `elk/logstash.conf` mounted at `/usr/share/logstash/pipeline/logstash.conf` |
| Auth       | Writes to Elasticsearch using `elastic` + `${ELASTIC_PASSWORD}` |
| Restart    | `unless-stopped`                                   |

#### Logstash Pipeline

**Input** — listens on `0.0.0.0:5044` for Beats-compatible agents (Filebeat, Metricbeat, Packetbeat, etc.).

**Filter** — auto-detects JSON messages. If the `message` field starts with `{`, Logstash parses it as JSON and promotes fields into the top-level event structure. Malformed JSON is skipped without dropping the event.

```ruby
filter {
  if [message] =~ /^\s*\{/ {
    json {
      source => "message"
      skip_on_invalid_json => true
    }
  }
}
```

**Output** — writes to Elasticsearch with a time-based index pattern:

```
enterprise-platform-YYYY.MM.dd
```

### Kibana

| Property               | Value                                             |
|------------------------|---------------------------------------------------|
| Image                  | `docker.elastic.co/kibana/kibana:8.15.2`          |
| Port                   | `5601`                                            |
| Elasticsearch URL      | `http://elasticsearch:9200`                       |
| Auth                   | `kibana_system` user + `${KIBANA_SYSTEM_PASSWORD}`|
| Restart                | `unless-stopped`                                  |

**URL**: `http://localhost:5601`

## Environment Variables

| Variable                  | Used By        | Purpose                             |
|---------------------------|----------------|-------------------------------------|
| `ELASTIC_PASSWORD`        | Logstash, Elasticsearch | Password for `elastic` superuser |
| `KIBANA_SYSTEM_PASSWORD`  | Kibana         | Password for `kibana_system` service account |

> **Security note**: Set these to strong, unique values at runtime via the `.env` file. Never commit credentials to source control.

## Index Naming and Retention

Indices follow the pattern `enterprise-platform-YYYY.MM.dd`. Retention is managed externally (e.g., an ILM policy or a scheduled curator job) — no automatic retention policy is configured in this `docker-compose.yml`.

## Data Flow

1. Services or Beats agents ship log events over TCP port `5044`.
2. Logstash receives events, optionally parses JSON, and enriches them.
3. Logstash writes the processed events to Elasticsearch under the daily index.
4. Kibana reads from Elasticsearch to display Discover views and dashboards.

## Local Access

```bash
cd observability
cp .env.example .env   # set ELASTIC_PASSWORD and KIBANA_SYSTEM_PASSWORD
docker compose up -d   # starts elasticsearch, logstash, kibana

# Elasticsearch
curl -s -u elastic:${ELASTIC_PASSWORD} http://localhost:9200

# Kibana
open http://localhost:5601
```

## Sending Logs from a Service

### Using Filebeat (example)

```yaml
filebeat.inputs:
  - type: log
    paths:
      - /var/log/myapp/*.log

output.logstash:
  hosts: ["localhost:5044"]
```

### Sending JSON-structured Logs Directly

Services that emit JSON to stdout can be collected and forwarded to Logstash. The Logstash JSON filter will automatically parse the `message` field.

## Integration with Grafana

Elasticsearch can be added as a data source in Grafana for log-based panels. Use the URL `http://elasticsearch:9200` and authenticate with the `elastic` user and `${ELASTIC_PASSWORD}`.

## Health Checks

```bash
# Elasticsearch cluster health
curl -s -u elastic:${ELASTIC_PASSWORD} http://localhost:9200/_cluster/health | jq

# Kibana server status
curl -s http://localhost:5601/api/status | jq
```

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu