# DevSecOps Infrastructure Project

## Overview

A production-grade AWS infrastructure built with Terraform, following a modular approach and a full DevSecOps workflow. The project covers infrastructure provisioning, GitOps delivery via ArgoCD, continuous security scanning with Trivy and SonarQube, full-stack monitoring with Prometheus and Grafana, and comprehensive IAM — all automated through GitHub Actions.

---

## Architecture

```
                          ┌─────────────────────────────────────────────┐
                          │                  AWS (us-east-1)            │
                          │                                             │
                          │   ┌──────────────────────────────────┐      │
                          │   │          VPC (10.0.0.0/16)       │      │
                          │   │                                  │      │
  Internet ──► Route53 ──►│   │  ┌─────────┐   ┌─────────┐      │      │
                          │   │  │ Public  │   │ Public  │      │      │
                          │   │  │Subnet1a │   │Subnet1b │      │      │
                          │   │  └────┬────┘   └────┬────┘      │      │
                          │   │       │    ALB       │           │      │
                          │   │  ┌────▼────┐   ┌────▼────┐      │      │
                          │   │  │Private  │   │Private  │      │      │
                          │   │  │Subnet1a │   │Subnet1b │      │      │
                          │   │  │(EC2/EKS)│   │(EC2/EKS)│      │      │
                          │   │  └────┬────┘   └────┬────┘      │      │
                          │   │       │              │           │      │
                          │   │  ┌────▼──────────────▼────┐      │      │
                          │   │  │     DB Subnets (RDS)   │      │      │
                          │   │  └────────────────────────┘      │      │
                          │   └──────────────────────────────────┘      │
                          └─────────────────────────────────────────────┘
```

---

## Project Structure

```
.
├── bootstrap/                  # Run once before terraform init — creates the S3 state bucket
│   ├── main.tf
│   ├── s3.tf
│   └── output.tf
├── vpc/                        # VPC, subnets, NAT gateways, route tables
├── ec2/                        # Bastion host + private servers with IAM instance profiles
├── alb/                        # Application Load Balancer (HTTPS, TLS 1.3)
├── auto-scalling/              # Auto Scaling Group attached to ALB
├── rds/                        # MySQL 8.0 RDS in private DB subnets
├── route53/                    # DNS alias record → ALB
├── iam/                        # EC2 instance role + RDS Secrets Manager role
├── eks/                        # EKS cluster, node group, OIDC, IRSA roles
├── argocd/                     # ArgoCD via Helm — GitOps controller
├── trivy/                      # Trivy Operator — continuous cluster scanning
├── sonarqube/                  # SonarQube server via Helm
├── monitoring/                 # kube-prometheus-stack (Prometheus, Grafana, AlertManager)
├── k8s/jupiter/                # Kubernetes manifests synced by ArgoCD
├── .github/workflows/          # GitHub Actions CI/CD pipelines
├── main.tf                     # Root module — wires all modules + providers
├── variables.tf                # All input variable declarations
├── dev.tfvars                  # Dev environment values
└── sonar-project.properties    # SonarQube project config
```

---

## Infrastructure Modules

| Module | Description |
|---|---|
| `bootstrap/` | Creates the S3 remote state bucket — run once with local backend before `terraform init` |
| `vpc/` | VPC, public/private/DB subnets across 2 AZs, 2 NAT Gateways, route tables |
| `ec2/` | Bastion host (public) + private app servers in az-1a and az-1b, all with IAM instance profiles |
| `alb/` | Application Load Balancer with HTTPS listener and TLS 1.3 policy |
| `auto-scalling/` | Auto Scaling Group (min 1, desired 4, max 6) attached to the ALB target group |
| `rds/` | MySQL 8.0 RDS in private DB subnets with Secrets Manager integration |
| `route53/` | Alias record pointing the domain to the ALB |
| `iam/` | EC2 instance role (SSM + CloudWatch) + RDS Secrets Manager role + instance profile |
| `eks/` | EKS cluster (k8s 1.30), managed node group, OIDC provider, ALB controller IRSA, Cluster Autoscaler IRSA |
| `argocd/` | ArgoCD via Helm — GitOps delivery, watches `k8s/jupiter/` and auto-syncs |
| `trivy/` | Trivy Operator on EKS — continuous CVE, RBAC, and misconfiguration scanning |
| `sonarqube/` | SonarQube server on EKS — static code analysis, 10Gi persistent storage |
| `monitoring/` | kube-prometheus-stack — Prometheus, Grafana, AlertManager, Node Exporter, kube-state-metrics |

---

## IAM Roles & Policies

| Role | Module | Policies |
|---|---|---|
| `ec2_instance_role` | `iam/` | `AmazonSSMManagedInstanceCore`, `CloudWatchAgentServerPolicy` |
| `rds_secrets_manager_role` | `iam/` | `secretsmanager:GetSecretValue` on the DB credentials secret |
| `eks_cluster_role` | `eks/` | `AmazonEKSClusterPolicy` |
| `eks_node_group_role` | `eks/` | `AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, `AmazonEC2ContainerRegistryReadOnly`, `CloudWatchAgentServerPolicy` |
| `alb_controller_role` (IRSA) | `eks/` | Full ALB management policy — bound to `kube-system/aws-load-balancer-controller` |
| `cluster_autoscaler_role` (IRSA) | `eks/` | ASG read/write policy — bound to `kube-system/cluster-autoscaler` |

> IRSA = IAM Roles for Service Accounts. Kubernetes pods assume these roles directly without using node credentials.

---

## Remote State — S3 Native Locking

State is stored in S3 with native locking (Terraform ≥ 1.10). No DynamoDB table required.

```hcl
backend "s3" {
  bucket       = "jupiter-terraform-state-<account-id>"
  key          = "jupiter/statefile"
  region       = "us-east-1"
  encrypt      = true
  use_lockfile = true   # S3 native locking — no DynamoDB needed
}
```

The bucket is created by the `bootstrap/` config and includes:
- **Versioning** — full history of every state file change
- **AES-256 encryption** — at rest
- **Public access blocked** — all four settings
- **Lifecycle rule** — non-current versions deleted after 90 days
- **`prevent_destroy = true`** — protected from accidental deletion

---

## DevSecOps Pipeline

Every push or pull request to `main` triggers this GitHub Actions pipeline (Terraform `~1.10`):

```
Git push / PR
     │
     ├── Terraform fmt -recursive
     ├── Terraform validate
     ├── Trivy IaC scan ──────────► GitHub Security tab (SARIF)
     ├── SonarQube scan ──────────► SonarQube server (code quality)
     │
     ├── [PR only]   Terraform plan
     │
     └── [merge to main]
           ├── Step 1: terraform apply -target=module.eks  (EKS first)
           └── Step 2: terraform apply                     (full stack)
```

After `terraform apply`:

```
EKS Cluster
  ├── ArgoCD          → watches k8s/jupiter/, auto-syncs on every commit
  ├── Trivy Operator  → continuously scans pods, images, RBAC, and infra config
  ├── SonarQube       → persistent analysis server (LoadBalancer, port 9000)
  └── Monitoring stack
        ├── Prometheus   → scrapes metrics from all workloads (15-day retention)
        ├── Grafana      → dashboards: Cluster, Node Exporter, Trivy findings
        └── AlertManager → alerting rules and notifications
```

---

## GitHub Actions Workflows

| Workflow | Trigger | What it does |
|---|---|---|
| `terraform.yml` | PR / push to `main` | fmt, validate, Trivy scan, SonarQube scan, plan (PR) / two-step apply (merge) |
| `terraform-destroy.yml` | Manual (`workflow_dispatch`) | Two-step destroy: Kubernetes workloads first, then infrastructure |
| `terraform-force-unlock-state.yml` | Manual (`workflow_dispatch`) | Force-unlocks a stuck S3 state lock using a provided lock ID |

### Why Two-Step Apply / Destroy

The `kubernetes` and `helm` providers are configured using the EKS cluster endpoint and CA certificate. They cannot initialise until the cluster exists.

**Apply order:**
1. `terraform apply -target=module.eks` — creates EKS cluster
2. `terraform apply` — deploys ArgoCD, Trivy, SonarQube, Monitoring, and all remaining resources

**Destroy order:**
1. `terraform destroy -target=module.argocd -target=module.trivy -target=module.sonarqube -target=module.monitoring` — removes Helm releases while EKS is still running
2. `terraform destroy` — tears down EKS, EC2, RDS, VPC, and all remaining infrastructure

---

## GitOps Flow (ArgoCD)

ArgoCD watches the `k8s/jupiter/` directory in this repository. Any change committed to that path is automatically detected and synced to the cluster — no manual `kubectl apply` needed.

```
k8s/jupiter/
  ├── namespace.yaml    — Kubernetes namespace
  ├── deployment.yaml   — 2-replica httpd deployment with liveness + readiness probes
  └── service.yaml      — LoadBalancer service on port 80
```

---

## Security Scanning

| Tool | Where it runs | What it scans |
|---|---|---|
| **Trivy (CI)** | GitHub Actions — every PR/push | Terraform IaC for misconfigurations → SARIF → GitHub Security tab |
| **Trivy Operator** | EKS — always on | Container images, RBAC, infra assessment, config audit |
| **SonarQube** | GitHub Actions + persistent server | Code quality, security bugs, code smells |

---

## Monitoring Dashboards

Grafana is pre-loaded with three dashboards:

| Dashboard | Grafana ID |
|---|---|
| Kubernetes Cluster overview | 7249 |
| Node Exporter (per-node CPU, memory, disk) | 1860 |
| Trivy Operator (CVE severity breakdown) | 17813 |

---

## First-Time Deploy Order

```bash
# Step 1 — create the S3 state bucket (one-time, uses local state)
cd bootstrap
terraform init
terraform apply
cd ..

# Step 2 — initialise the root config with the new S3 backend
terraform init

# Step 3 — create EKS first (kubernetes/helm providers need the cluster)
terraform apply -target=module.eks -var-file=dev.tfvars

# Step 4 — deploy the full stack
terraform apply \
  -var-file=dev.tfvars \
  -var="grafana_admin_password=<your-password>"
```

---

## GitHub Secrets Required

| Secret | Used by |
|---|---|
| `AWS_ACCESS_KEY_ID` | All workflows — AWS provider authentication |
| `AWS_SECRET_ACCESS_KEY` | All workflows — AWS provider authentication |
| `GRAFANA_ADMIN_PASSWORD` | Terraform apply/destroy — Grafana admin login |
| `SONAR_TOKEN` | `terraform.yml` — SonarQube scanner authentication |
| `SONAR_HOST_URL` | `terraform.yml` — SonarQube server URL (LoadBalancer endpoint after deploy) |

---

## Tech Stack

- **Infrastructure as Code** — Terraform ≥ 1.10 (modular)
- **Cloud** — AWS (VPC, EC2, ALB, ASG, RDS, EKS, Route53, IAM, S3, Secrets Manager)
- **GitOps** — ArgoCD
- **Security Scanning** — Trivy, SonarQube
- **Monitoring** — Prometheus, Grafana, AlertManager, Node Exporter, kube-state-metrics
- **CI/CD** — GitHub Actions
- **Container Orchestration** — Kubernetes (EKS 1.30)
- **Helm** — ArgoCD, Trivy Operator, SonarQube, kube-prometheus-stack
