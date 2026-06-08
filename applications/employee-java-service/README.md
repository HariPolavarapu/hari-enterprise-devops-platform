# Employee Java Service

Spring Boot based Employee Management Microservice for the Hari Enterprise DevOps Platform.

## Stack

* Java 17
* Spring Boot
* Maven
* PostgreSQL
* Docker
* Jenkins
* Kubernetes
* AWS EKS
* ArgoCD

---

## Features

* Employee CRUD APIs
* RESTful backend architecture
* PostgreSQL integration
* Dockerized deployment
* CI/CD ready

---

## API Endpoints

| Method | Endpoint        | Description        |
| ------ | --------------- | ------------------ |
| GET    | /employees      | Get all employees  |
| GET    | /employees/{id} | Get employee by ID |
| POST   | /employees      | Create employee    |
| DELETE | /employees/{id} | Delete employee    |

---

## Build

```bash
mvn clean package
```

---

## Run

```bash
mvn spring-boot:run
```

---

## Docker

```bash
docker build -t employee-service .
```

---

## Deployment Flow

GitHub → Jenkins → Docker → AWS ECR → ArgoCD → AWS EKS

---

## Maintained By

Hari Krishna Polavarapu
