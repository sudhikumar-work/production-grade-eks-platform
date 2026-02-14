# Production-Grade EKS Platform

**Author:** Sudheeshkumar Surendran  
**Document Type:** Infrastructure Design Proposal  
**Status:** Implemented  
**Last Updated:** 2026  

---

# 1. Overview

This document describes the design, architecture, and operational model of a production-grade Kubernetes platform built on AWS.

The objective of this platform is to provide:

- Secure multi-tenant Kubernetes infrastructure
- Environment isolation (dev/staging/prod)
- Strong identity boundaries
- Infrastructure immutability
- Operational observability
- Cost-aware scalability

This is not a demo deployment.  
This system is designed to reflect real production constraints and failure modes.

---

# 2. Problem Statement

Engineering teams require:

- A standardized Kubernetes control plane
- Secure workload identity separation
- Repeatable environment provisioning
- Automated infrastructure lifecycle management
- Observability before scale
- Controlled blast radius between environments

The platform must:

- Avoid privilege escalation risk
- Avoid manual configuration drift
- Scale horizontally without architectural redesign
- Minimize long-term operational overhead

---

# 3. Goals & Non-Goals

## 3.1 Goals

- Multi-environment infrastructure (dev, staging, prod)
- Private networking by default
- Workload-level IAM isolation
- Declarative infrastructure lifecycle
- CI-driven deployments
- Horizontal scalability at pod and node levels

## 3.2 Non-Goals

- Multi-cloud abstraction
- On-prem hybrid connectivity
- Custom Kubernetes control plane management
- Service mesh implementation (future iteration)

---

# 4. System Architecture

## 4.1 High-Level Architecture

- VPC spanning 3 Availability Zones
- Public subnets for ALB only
- Private subnets for EKS worker nodes
- Isolated database subnets
- NAT Gateway for controlled outbound traffic
- IRSA-based workload identity
- RDS Multi-AZ PostgreSQL
- Observability stack deployed within cluster
- Terraform remote state with locking

---

# 5. Detailed Design

## 5.1 Networking Model

- Worker nodes are deployed in private subnets.
- No public IP addresses assigned to nodes.
- Ingress traffic enters exclusively via ALB.
- Database tier is not internet routable.
- NAT Gateway provides controlled outbound egress.

### Design Rationale

- Eliminates node-level public attack surface.
- Forces ingress through managed load balancing layer.
- Preserves least exposure model.

### Tradeoff

NAT Gateway introduces fixed monthly cost overhead in exchange for secure outbound access.

---

## 5.2 Identity Model

### Workload Identity (IRSA)

Each workload receives a scoped IAM role via OIDC federation.

Flow:

1. OIDC provider registered for EKS cluster.
2. IAM role created with restrictive trust policy.
3. Kubernetes ServiceAccount annotated with IAM role ARN.
4. Pod assumes temporary credentials through projected service account token.

### Why Not Node IAM?

Using node IAM would:

- Expand blast radius.
- Enable lateral privilege escalation.
- Violate least-privilege principle.

IRSA enforces identity boundaries at workload level.

---

## 5.3 Infrastructure Lifecycle

Infrastructure is provisioned using Terraform.

Remote state backend:

- S3 for state storage.
- DynamoDB for state locking.

Terragrunt controls:

- Environment-specific configuration.
- State isolation.
- DRY module orchestration.

Each environment has:

- Separate state.
- Separate RDS instance.
- Isolated namespaces.

No manual console modifications are permitted.

---

## 5.4 Database Design

- Multi-AZ PostgreSQL.
- Private subnet placement.
- Storage encryption enabled.
- Automated backups configured.
- IAM and security group restrictions applied.

### Rationale

Database availability must remain independent of Kubernetes node lifecycle.

Tradeoff: Higher operational cost in exchange for high availability.

---

## 5.5 Observability Model

Observability is treated as infrastructure, not an afterthought.

Components:

- Prometheus for metrics aggregation.
- Grafana for visualization.
- Loki for centralized logging.
- Alertmanager for alert routing.
- CloudWatch for AWS-native metrics.

Alerting configured for:

- Pod crash loops
- CPU throttling
- Memory pressure
- Node health degradation
- Deployment failures

---

# 6. Deployment Strategy

## 6.1 Infrastructure Pipeline

- Terraform format validation
- Static analysis
- Terraform plan
- Manual approval for production
- Terraform apply

All infrastructure changes are PR-driven.

---

## 6.2 Application Deployment

- Docker image build
- Push to ECR
- Helm upgrade
- Rolling deployment strategy
- Liveness and readiness validation

Deployments must be reversible without cluster recreation.

---

# 7. Scalability Model

## Pod Scaling

- Horizontal Pod Autoscaler based on CPU metrics.

## Node Scaling

- Managed Node Groups with autoscaling enabled.

Future enhancement:

- Event-driven node provisioning (e.g., Karpenter).

---

# 8. Failure Scenarios & Mitigations

| Failure | Mitigation |
|----------|------------|
| Node failure | Kubernetes rescheduling |
| AZ outage | Multi-AZ node groups |
| RDS failure | Multi-AZ automatic failover |
| Bad deployment | Helm rollback |
| Infrastructure drift | Immutable IaC enforcement |

---

# 9. Security Considerations

- No public worker nodes.
- TLS termination at ALB.
- WAF rules at ingress layer.
- IAM policies scoped to minimum privilege.
- No plaintext secrets stored in repository.
- Secrets stored in AWS Secrets Manager.

---

# 10. Cost Considerations

Primary cost drivers:

- NAT Gateway
- EKS control plane
- RDS Multi-AZ
- ALB

Estimated dev baseline:

~$200–$350 per month.

Scaling is elastic at pod and node levels to prevent overprovisioning.

---

# 11. Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Over-permissioned IAM | Strict IRSA enforcement |
| State corruption | DynamoDB locking |
| Manual drift | CI-enforced Terraform apply |
| Cost escalation | Autoscaling + resource monitoring |

---

# 12. Future Enhancements

- GitOps via ArgoCD
- Policy enforcement via OPA or Kyverno
- Cross-region disaster recovery
- FinOps dashboard integration
- Service mesh implementation

---

# 13. Why This Design Matters

This architecture prioritizes:

- Blast radius control
- Identity isolation
- Infrastructure immutability
- Operational observability
- Realistic production constraints


---

# Author

Sudheeshkumar Surendran  
Cloud & Platform Engineer  
Pune, India  
