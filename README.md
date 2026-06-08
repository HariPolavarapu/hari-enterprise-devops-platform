# Hari Enterprise DevOps Platform

Enterprise-grade cloud-native DevOps platform designed and maintained by Hari Krishna Polavarapu.

This project demonstrates end-to-end DevOps, GitOps, Kubernetes, CI/CD, Infrastructure as Code, observability, and cloud engineering practices using a production-style microservices architecture.

---

# Architecture Overview

The platform is designed around containerized microservices deployed on AWS EKS using GitOps workflows and automated CI/CD pipelines.

## Core Architecture

Frontend Applications
→ Backend Microservices
→ Docker Containers
→ AWS ECR
→ ArgoCD GitOps
→ AWS EKS Cluster

---

# Technology Stack

## Cloud & Infrastructure

* AWS
* EKS
* EC2
* VPC
* IAM
* ALB
* Route53
* CloudWatch
* S3
* RDS

---

## CI/CD & GitOps

* GitHub
* Jenkins
* ArgoCD
* Docker
* AWS ECR

---

## Infrastructure Automation

* Terraform
* Ansible

---

## Monitoring & Observability

* Prometheus
* Grafana
* ELK Stack
* Tempo
* CloudWatch

---

## Security & DevSecOps

* HashiCorp Vault
* Trivy
* SonarQube
* Kubernetes RBAC

---

# Microservices

## Employee Java Service

Spring Boot based Employee Management backend microservice.

### Stack

* Java 17
* Spring Boot
* Maven
* PostgreSQL

---

## Notification Python Service

FastAPI based notification and alerting microservice.

### Stack

* Python
* FastAPI
* Uvicorn

---

## Frontend Angular

Frontend portal application for enterprise platform operations.

### Stack

* Angular
* NGINX

---

## Payroll Dotnet Service

Payroll processing and salary management microservice.

### Stack

* .NET
* ASP.NET Core

---

# Repository Structure

```text id="e0e4vy"
applications/
cicd/
gitops/
infrastructure/
observability/
security/
operations/
docs/
```

---

# CI/CD Flow

GitHub
→ Jenkins Pipeline
→ Build & Testing
→ SonarQube Scan
→ Trivy Security Scan
→ Docker Build
→ AWS ECR Push
→ ArgoCD Sync
→ AWS EKS Deployment

---

# Infrastructure

Infrastructure provisioning is managed using Terraform modules for:

* VPC
* EKS
* EC2
* IAM
* ALB
* RDS
* ECR
* Route53
* CloudWatch

---

# GitOps Deployment Strategy

ArgoCD continuously monitors Git repositories and synchronizes Kubernetes manifests into the EKS cluster.

Deployment manifests, Helm charts, and ArgoCD applications are maintained inside the GitOps layer of the repository.

---

# Monitoring & Logging

The platform integrates centralized monitoring and observability using:

* Prometheus
* Grafana
* ELK Stack
* Tempo
* AWS CloudWatch

---

# Security

Security implementation includes:

* Container image scanning using Trivy
* Code quality validation using SonarQube
* Vault-based secrets management
* Kubernetes RBAC
* Secure container registry usage

---

# DevOps Engineering Practices

* Infrastructure as Code
* GitOps
* CI/CD Automation
* Containerized Microservices
* Kubernetes Orchestration
* Environment-based Deployments
* Centralized Monitoring
* Security Scanning
* Operational Documentation

---

# Maintained By

Hari Krishna Polavarapu

DevOps Engineer

GitHub:
https://github.com/HariPolavarapu
