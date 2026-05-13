# AWS Enterprise DevSecOps Platform — App CI/CD

## Overview

Companion repository to [Terraform-infra-project-004](https://github.com/Elhadji12680/Terraform-infra-project-004).

Handles the application lifecycle: building a containerized app, security scanning the image with Trivy, pushing to Amazon ECR, and deploying to the EKS cluster provisioned by the infrastructure repo.

---

## Repository Structure

```
.
├── app/
│   ├── src/
│   │   └── index.html          # Application source
│   ├── Dockerfile              # Multi-stage build — nginx:alpine, non-root user
│   └── .dockerignore
├── k8s/
│   ├── namespace.yaml          # jupiter namespace
│   ├── deployment.yaml         # 2-replica deployment, resource limits, security context
│   └── service.yaml            # LoadBalancer service on port 80
├── .github/workflows/
│   ├── build-scan-push.yml     # Build → Trivy scan → push to ECR  (manual trigger)
│   └── deploy.yml              # Deploy image tag to EKS            (manual trigger)
└── sonar-project.properties
```

---

## Pipelines

Both pipelines are set to **manual trigger only** (`workflow_dispatch`). They will not run automatically on push or PR.

| Workflow | Trigger | What it does |
|---|---|---|
| `build-scan-push.yml` | Manual | Docker build → Trivy image scan (SARIF → GitHub Security) → push to ECR |
| `deploy.yml` | Manual | Updates the running deployment on EKS with the specified image tag |

To run a pipeline: **Actions → select workflow → Run workflow → enter tag**.

---

## GitHub Secrets Required

| Secret | Used by |
|---|---|
| `AWS_ACCESS_KEY_ID` | Both workflows |
| `AWS_SECRET_ACCESS_KEY` | Both workflows |

---

## How It Fits the Platform

```
This repo                          Infrastructure repo (Terraform-infra-project-004)
─────────────────────────          ──────────────────────────────────────────────────
app/ ──► Dockerfile                VPC, EC2, ALB, ASG, RDS
         │                         EKS cluster + node group
         ▼                         ArgoCD (watches k8s/ in this repo)
ECR image                          Trivy Operator (scans running pods)
         │                         Prometheus + Grafana (monitors cluster)
         ▼
k8s/ ──► ArgoCD syncs ──► EKS
```

---

## Tech Stack

- **Container Runtime** — Docker (nginx:1.27-alpine, non-root)
- **Registry** — Amazon ECR
- **Orchestration** — Kubernetes (EKS 1.30)
- **GitOps** — ArgoCD
- **Security Scanning** — Trivy (image scan), SonarQube (code quality)
- **CI/CD** — GitHub Actions (manual trigger)
- **Cloud** — AWS (us-east-1)
