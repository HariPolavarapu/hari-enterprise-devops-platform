# Employee Service

A Spring Boot 3 REST API for managing employee records, providing full CRUD operations backed by PostgreSQL with observability via Spring Actuator and Micrometer Prometheus metrics.

## Technology Stack

| Component    | Version      |
|--------------|--------------|
| Java         | 17           |
| Spring Boot  | 3.3.0        |
| Maven        | 3.9.9        |
| Database     | PostgreSQL   |
| Test DB      | H2 (in-memory)|
| Metrics      | Micrometer + Prometheus |
| Coverage     | JaCoCo 0.8.12 |

## Building the Service

### Prerequisites

- Java 17 JDK
- Maven 3.9+
- PostgreSQL 14+ (for local runtime)

### Build with Maven

```bash
# Compile and run tests (H2 in-memory database, no external deps)
mvn clean verify

# Package without running tests
mvn clean package -DskipTests
```

### Build with Docker

```bash
docker build -t employee-service:1.0.0 .
```

## Running the Service

### Without Docker

```bash
# Set required environment variables
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=employee_db
export DB_USERNAME=postgres
export DB_PASSWORD=your_password

# Run the packaged JAR
java -jar target/employee-service-1.0.0.jar
```

### With Docker

```bash
docker run -d \
  --name employee-service \
  -p 8080:8080 \
  -e DB_HOST=host.docker.internal \
  -e DB_PORT=5432 \
  -e DB_NAME=employee_db \
  -e DB_USERNAME=postgres \
  -e DB_PASSWORD=your_password \
  employee-service:1.0.0
```

### With Docker Compose (existing infrastructure)

```bash
docker compose up -d employee-service
```

## Environment Variables

| Variable          | Required | Default | Description                        |
|-------------------|----------|---------|------------------------------------|
| `DB_HOST`         | Yes      | localhost| PostgreSQL hostname                |
| `DB_PORT`         | No       | 5432    | PostgreSQL port                    |
| `DB_NAME`         | Yes      | —       | Database name                      |
| `DB_USERNAME`     | Yes      | —       | Database username                  |
| `DB_PASSWORD`     | Yes      | —       | Database password                  |
| `SERVER_PORT`     | No       | 8080    | Application listen port            |

> **Security Note:** Never commit database credentials to source control. Use Kubernetes secrets or a secrets manager for production deployments.

## API Endpoints

### Employee Management

| Method | Path              | Description              | Request Body         |
|--------|-------------------|--------------------------|----------------------|
| `POST` | `/employees`      | Create a new employee    | `Employee` JSON      |
| `GET`  | `/employees`      | List all employees       | —                    |
| `GET`  | `/employees/{id}` | Get employee by ID       | —                    |
| `DELETE`| `/employees/{id}` | Delete employee by ID    | —                    |

#### Employee JSON Schema

```json
{
  "id": 1,
  "name": "Jane Smith",
  "email": "jane.smith@company.com",
  "department": "Engineering",
  "salary": 85000.00
}
```

## Health Check & Observability

| Endpoint                        | Description                          |
|---------------------------------|--------------------------------------|
| `GET /api/actuator/health`      | Liveness/readiness probe             |
| `GET /api/actuator/prometheus`  | Prometheus metrics scrape endpoint   |

### Health Check

```bash
curl http://localhost:8080/api/actuator/health
# {"status":"UP"}
```

### Prometheus Metrics

```bash
curl http://localhost:8080/api/actuator/prometheus
```

## Port Mappings

| Service       | Container Port | Host Port |
|---------------|----------------|-----------|
| Employee API  | 8080           | 8080      |
| H2 Console    | —              | Disabled in prod |

## Project Structure

```
employee-java-service/
├── src/
│   ├── main/java/com/enterprise/platform/employee/
│   │   ├── controller/   EmployeeController.java
│   │   ├── dto/          EmployeeDTO.java
│   │   ├── entity/       Employee.java
│   │   ├── exception/    GlobalExceptionHandler.java, EmployeeNotFoundException.java
│   │   ├── repository/   EmployeeRepository.java
│   │   ├── service/      EmployeeService.java
│   │   └── EmployeeServiceApplication.java
│   └── test/java/.../EmployeeServiceApplicationTests.java
├── pom.xml
├── Dockerfile
└── Jenkinsfile
```

## Database Schema

The `employees` table is auto-created by Hibernate on first startup:

```sql
CREATE TABLE employees (
    id         BIGSERIAL PRIMARY KEY,
    name       VARCHAR(255) NOT NULL,
    email      VARCHAR(255) NOT NULL UNIQUE,
    department VARCHAR(255),
    salary     DOUBLE PRECISION
);
```

## Testing

```bash
# Run unit and integration tests (uses isolated H2 database)
mvn test

# Run with code coverage report
mvn verify
# JaCoCo report at: target/site/jacoco/index.html
```

## Docker Details

- **Base image (build):** `maven:3.9.9-eclipse-temurin-17`
- **Base image (runtime):** `eclipse-temurin:17-jre-alpine`
- **Non-root user:** `app` (UID `65532`, GID `app`)
- **Health check:** `wget -qO- http://localhost:8080/api/actuator/health`

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu