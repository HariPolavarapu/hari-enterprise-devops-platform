# Payroll Service

An ASP.NET Core 8 REST API for payroll operations, providing endpoints to retrieve, calculate, and process payroll records with Prometheus metrics and Swagger documentation.

## Technology Stack

| Component            | Version    |
|----------------------|------------|
| .NET                 | 8.0        |
| ASP.NET Core         | 8.0        |
| C#                   | 12         |
| Swagger/OpenAPI      | Swashbuckle.AspNetCore 6.6.2 |
| Metrics              | prometheus-net.AspNetCore 8.2.1 |

## Building the Service

### Prerequisites

- .NET 8.0 SDK

### Build Locally

```bash
dotnet restore
dotnet build -c Release
```

### Run Tests

```bash
dotnet test
```

### Build with Docker

```bash
docker build -t payroll-service:1.0.0 .
```

## Running the Service

### Without Docker

```bash
dotnet run --project .
# Listens on http://localhost:8080 by default (ASPNETCORE_URLS=http://+:8080)
```

### With Docker

```bash
docker run -d \
  --name payroll-service \
  -p 8080:8080 \
  payroll-service:1.0.0
```

### With Docker Compose (existing infrastructure)

```bash
docker compose up -d payroll-service
```

## Environment Variables

| Variable          | Required | Default | Description                        |
|-------------------|----------|---------|------------------------------------|
| `ASPNETCORE_ENVIRONMENT` | No | (none) | `Development` enables Swagger UI  |
| `ASPNETCORE_URLS` | No | `http://+:8080` | Listen endpoints             |

## API Endpoints

Base path: `/api/payroll`

| Method | Path                  | Description                     | Request Body    |
|--------|-----------------------|---------------------------------|-----------------|
| `GET`  | `/api/payroll/{id}`   | Retrieve payroll by ID          | —               |
| `POST` | `/api/payroll/calculate` | Calculate payroll for employee | `int` (employeeId) |
| `POST` | `/api/payroll/process`   | Process payroll by payroll ID   | `int` (payrollId)  |

### Response Wrapper

All endpoints return an `ApiResponse<T>`:

```json
{
  "success": true,
  "message": "Payroll retrieved successfully",
  "data": {
    "id": 42,
    "status": "Paid"
  }
}
```

#### Payroll Model

```json
{
  "id": 42,
  "status": "Paid"
}
```

#### PaymentStatus Enum

- `Pending`
- `Paid`
- `Failed`

### GET /api/payroll/{id}

```bash
curl http://localhost:8080/api/payroll/42
```

### POST /api/payroll/calculate

```bash
curl -X POST http://localhost:8080/api/payroll/calculate \
  -H "Content-Type: application/json" \
  -d 42
```

### POST /api/payroll/process

```bash
curl -X POST http://localhost:8080/api/payroll/process \
  -H "Content-Type: application/json" \
  -d 42
```

## Health Check & Observability

| Endpoint     | Description                     |
|--------------|---------------------------------|
| `GET /health`| Returns `{"status":"ok","service":"payroll-service"}` |
| `GET /metrics`| Prometheus metrics scrape endpoint |

### Health Check

```bash
curl http://localhost:8080/health
```

### Prometheus Metrics

```bash
curl http://localhost:8080/metrics
```

Metrics include HTTP request duration, request count, and active requests via `prometheus-net.AspNetCore`.

## Swagger UI (Development Only)

When `ASPNETCORE_ENVIRONMENT=Development`, Swagger UI is available at:

```
http://localhost:8080/swagger
```

## Port Mappings

| Service     | Container Port | Host Port |
|-------------|----------------|-----------|
| Payroll API | 8080           | 8080      |

## Project Structure

```
payroll-dotnet-service/
├── Controllers/
│   └── PayrollController.cs     # REST endpoints
├── Models/
│   ├── ApiResponse.cs           # Standard response wrapper
│   ├── Employee.cs              # Employee model
│   ├── Payroll.cs               # Payroll model + PaymentStatus enum
│   └── PayrollService.cs        # Business logic interface
├── Services/
│   └── PayrollService.cs        # IPayrollService implementation
├── Program.cs                   # Application entry, DI, middleware
├── appsettings.json             # Production config
├── appsettings.Development.json # Dev config (Swagger enabled)
├── payroll.csproj
├── Dockerfile
└── Jenkinsfile
```

## Testing

```bash
dotnet test
```

## Docker Details

- **Base image (build):** `mcr.microsoft.com/dotnet/sdk:8.0`
- **Base image (runtime):** `mcr.microsoft.com/dotnet/aspnet:8.0`
- **Non-root user:** `app` (system group and user)
- **Health check:** Docker does not define a HEALTHCHECK; use `/health` endpoint for manual probes.

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu