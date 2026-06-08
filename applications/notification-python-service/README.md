# Notification Python Service

FastAPI based Notification Microservice for the Hari Enterprise DevOps Platform.

## Stack

* Python
* FastAPI
* Uvicorn
* Docker
* Jenkins
* Kubernetes
* AWS EKS
* ArgoCD

---

## Features

* Email notification APIs
* Health check endpoint
* Lightweight async microservice
* Dockerized deployment
* CI/CD ready

---

## API Endpoints

| Method | Endpoint      | Description             |
| ------ | ------------- | ----------------------- |
| GET    | /health       | Health check            |
| POST   | /notify/email | Send email notification |

---

## Run

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

---

## Docker

```bash
docker build -t notification-service .
```

---

## Deployment Flow

GitHub → Jenkins → Docker → AWS ECR → ArgoCD → AWS EKS

---

## Maintained By

Hari Krishna Polavarapu
