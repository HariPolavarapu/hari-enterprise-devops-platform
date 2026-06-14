# Notification Service

A FastAPI-based microservice for sending email notifications, with integrated Prometheus instrumentation for observability and structured logging.

## Technology Stack

| Component                | Version    |
|--------------------------|------------|
| Python                   | 3.12       |
| FastAPI                  | (from requirements.txt) |
| Uvicorn                  | (from requirements.txt) |
| Pydantic                 | (from requirements.txt) |
| python-dotenv            | (from requirements.txt) |
| prometheus-fastapi-instrumentator | (from requirements.txt) |
| pytest / httpx           | (dev/test only) |

## Building the Service

### Prerequisites

- Python 3.12
- SMTP server (for email delivery)

### Install Dependencies

```bash
pip install -r requirements.txt
```

### Run Tests

```bash
pytest
```

### Build with Docker

```bash
docker build -t notification-service:1.0.0 .
```

## Running the Service

### Without Docker

```bash
# Configure environment variables (see Environment Variables section)
cp .env.example .env  # if an example file exists, otherwise set exports below

uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### With Docker

```bash
docker run -d \
  --name notification-service \
  -p 8000:8000 \
  -e SMTP_HOST=smtp.company.com \
  -e SMTP_PORT=587 \
  -e SMTP_USER=notifications@company.com \
  -e SMTP_PASSWORD=your_smtp_password \
  -e SMTP_FROM=no-reply@company.com \
  notification-service:1.0.0
```

### With Docker Compose (existing infrastructure)

```bash
docker compose up -d notification-service
```

## Environment Variables

| Variable        | Required | Default                    | Description                        |
|-----------------|----------|----------------------------|------------------------------------|
| `SMTP_HOST`     | Yes*     | (empty)                    | SMTP server hostname               |
| `SMTP_PORT`     | No       | 587                        | SMTP port (TLS)                    |
| `SMTP_USER`     | Yes*     | (empty)                    | SMTP username                      |
| `SMTP_PASSWORD` | Yes*     | (empty)                    | SMTP password                      |
| `SMTP_FROM`     | No       | no-reply@platform.invalid  | Sender email address               |
| `SMTP_STARTTLS` | No       | true                       | Enable STARTTLS on connect         |
| `DATABASE_URL`  | No       | sqlite:///./notifications.db | Database connection URL          |
| `DEBUG`         | No       | false                      | Enable debug mode                  |
| `LOG_LEVEL`     | No       | INFO                       | Logging level (DEBUG, INFO, etc.)  |
| `API_HOST`      | No       | 0.0.0.0                    | Bind address                       |
| `API_PORT`      | No       | 8080                       | Listen port (internal, use 8000 externally) |

> \* Required for email delivery to function. The service starts without them but `POST /notify/email` will fail if SMTP is not configured.

> **Security Note:** Never commit SMTP credentials to source control. Use environment variables, Kubernetes secrets, or a secrets manager for production deployments.

## API Endpoints

### Send Email Notification

```
POST /notify/email
Content-Type: application/json
```

**Request Body**

```json
{
  "email": "recipient@example.com",
  "subject": "Payroll Notification",
  "message": "Your payroll for June 2026 has been processed."
}
```

**Response**

```json
HTTP 200 OK
{
  "status": "accepted"
}
```

**Validation Error Response**

```json
HTTP 422 Unprocessable Entity
{
  "detail": [
    {
      "loc": ["body", "email"],
      "msg": "value is not a valid email address",
      "type": "value_error"
    }
  ]
}
```

### Health Check

```
GET /health
```

**Response**

```json
{
  "status": "ok",
  "service": "notification-service"
}
```

### Prometheus Metrics

```
GET /metrics
```

Exposes HTTP request metrics (latency, request count, error rate) via the `prometheus-fastapi-instrumentator`.

## Health Check

```bash
curl http://localhost:8000/health
```

Docker health check:

```bash
docker inspect --format='{{.State.Health.Status}}' notification-service
# healthy | unhealthy | starting
```

## Port Mappings

| Service             | Container Port | Host Port |
|---------------------|----------------|-----------|
| Notification API    | 8000           | 8000      |

## Project Structure

```
notification-python-service/
├── app/
│   ├── main.py          # FastAPI app entrypoint
│   ├── config.py        # Environment-driven configuration
│   ├── logger.py        # Structured logging setup
│   ├── models/
│   │   └── notification.py
│   ├── routes/
│   │   └── notification_routes.py  # /notify/email endpoint
│   ├── services/
│   │   └── notification_service.py # EmailService.send_email()
│   └── utils/
│       └── helpers.py
├── tests/
├── requirements.txt
├── Dockerfile
└── Jenkinsfile
```

## Email Delivery

The `EmailService` uses the configured SMTP credentials to deliver email via the Python standard library's `smtplib`. STARTTLS is used when `SMTP_STARTTLS=true` (the default).

## Testing

```bash
# Run all tests (FastAPI TestClient, no external dependencies)
pytest -v

# Run with coverage
pytest --cov=app --cov-report=html
```

## Docker Details

- **Base image (build):** `python:3.12-slim`
- **Base image (runtime):** `python:3.12-slim`
- **Non-root user:** `app` (system group and user)
- **Health check:** `python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"`

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu