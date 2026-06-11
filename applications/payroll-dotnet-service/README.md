# Payroll Dotnet Service

ASP.NET Core based Payroll Management Microservice for the Hari Enterprise DevOps Platform.

## Stack

- .NET 8
- ASP.NET Core
- Docker
- Jenkins
- Kubernetes
- AWS EKS
- ArgoCD

---

## Features

- Payroll Management APIs
- Salary Processing
- Employee Compensation APIs
- Dockerized Deployment
- CI/CD Ready

---

## API Endpoints

| Method | Endpoint | Description |
|----------|----------|-------------|
| GET | /payroll | Get payroll records |
| GET | /payroll/{id} | Get payroll by ID |
| POST | /payroll | Create payroll |
| DELETE | /payroll/{id} | Delete payroll |

---

## Build

dotnet build

---

## Run

dotnet run

---

## Docker

docker build -t payroll-service .

---

## Deployment Flow

GitHub → Jenkins → Docker → AWS ECR → ArgoCD → AWS EKS

---

## Maintained By

Hari Krishna Polavarapu