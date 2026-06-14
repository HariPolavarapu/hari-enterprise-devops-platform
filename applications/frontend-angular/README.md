# Enterprise Platform Frontend

An Angular 17 single-page application (SPA) serving as the web interface for the enterprise DevOps platform. The application is containerized with NGINX and requires no runtime Node.js environment.

## Technology Stack

| Component              | Version      |
|------------------------|--------------|
| Angular                | 17.0.0       |
| TypeScript             | ~5.2.0       |
| Node.js (build only)   | 22           |
| NGINX                  | (alpine)     |
| RxJS                   | ^7.8.0       |
| Zone.js                | ^0.14.0      |
| Karma / Jasmine        | (dev/test)   |

## Building the Service

### Prerequisites

- Node.js 22 (for local development/build only)
- npm 10+

### Install Dependencies

```bash
npm install
```

### Run Tests

```bash
# Unit tests (Karma + Jasmine)
npm test

# End-to-end tests
npm run e2e
```

### Lint

```bash
npm run lint
```

### Build Locally

```bash
npm run build
# Output: dist/frontend/
```

### Build with Docker

The Docker build runs `npm install` and `npm run build` in a multi-stage build, producing a production-optimized NGINX image.

```bash
docker build -t enterprise-frontend:1.0.0 .
```

## Running the Service

### Without Docker (Development Server)

```bash
npm start
# Serves on http://localhost:4200 with live reload
```

### With Docker

```bash
docker run -d \
  --name enterprise-frontend \
  -p 8080:8080 \
  enterprise-frontend:1.0.0
```

### With Docker Compose (existing infrastructure)

```bash
docker compose up -d frontend
```

## Routes

The application uses Angular Router with the following routes:

| Path          | Component         | Description                         |
|---------------|-------------------|-------------------------------------|
| `/`           | redirect → `/home`| Redirects to home                   |
| `/home`       | HomeComponent     | Home page                           |
| `/dashboard`  | DashboardComponent| Dashboard view                      |
| `/employees`  | EmployeeComponent | Employee management view            |
| `/**`         | redirect → `/home`| Catch-all, returns to home          |

## NGINX Configuration

The application is served by NGINX (Alpine) on port 8080. The NGINX configuration uses `try_files` to support Angular's client-side routing — all unmatched routes fall back to `index.html`.

```nginx
server {
    listen 8080;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

## Port Mappings

| Service      | Container Port | Host Port |
|--------------|----------------|-----------|
| Frontend     | 8080           | 8080      |

## Project Structure

```
frontend-angular/
├── src/
│   └── app/
│       ├── app.component.ts       # Root component
│       ├── app.config.ts          # Application configuration
│       ├── app.routes.ts          # Route definitions
│       └── pages/
│           ├── home/              # HomeComponent
│           ├── dashboard/         # DashboardComponent
│           └── employee/          # EmployeeComponent
├── angular.json
├── package.json
├── tsconfig.json
├── tsconfig.spec.json
├── nginx.conf                     # NGINX configuration
├── Dockerfile
└── Jenkinsfile
```

## Testing

### Unit Tests

```bash
npm test
# Runs Karma with Jasmine, watches for file changes
# Coverage report generated via karma-coverage
```

### End-to-End Tests

```bash
npm run e2e
# Runs Protractor e2e tests
```

## Docker Details

- **Build stage:** `node:22-alpine` — runs `npm install` and `npm run build`
- **Runtime stage:** `nginx:alpine` — serves the built application
- **Non-root user:** `app` (UID/GID `app`)
- **No health check defined** — the NGINX process is the application; external orchestration should TCP-check port 8080.

## Environment Variables

This is a static Angular SPA served by NGINX. No server-side environment variables are used. For build-time environment substitution, Angular supports `environment.ts` files; refer to the Angular documentation for managing environment-specific builds.

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu