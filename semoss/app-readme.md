# SEMOSS

SEMOSS is an AI/ML platform for building, deploying, and managing AI applications. This chart deploys SEMOSS on Kubernetes backed by external PostgreSQL databases and cloud object storage.

## Architecture

- **semoss** — main application pod running Tomcat + Python runtime
- **ingress** — nginx with sticky-session cookie affinity for multi-replica deployments
- **zookeeper** — optional; required when `replicaCount > 1` for cluster coordination

All system state (databases, user files) lives outside the pod. Pods are stateless and use `strategy: Recreate`.

## Prerequisites

| Component | Requirement |
|---|---|
| Kubernetes | 1.21+ |
| Helm | 3.x |
| nginx ingress controller | any recent version |
| PostgreSQL | 5 system databases pre-created |
| Object storage | Azure Blob, S3, GCS, MinIO, or LOCAL |

## System Databases

Five PostgreSQL databases must exist before install:

| Database | Default name | Purpose |
|---|---|---|
| security | `security` | Users, groups, and access control |
| localmaster | `localmaster` | App/engine catalog |
| scheduler | `scheduler` | Background job scheduling |
| themes | `themes` | UI theme configuration |
| usertracking | `user_tracking` | Usage analytics |

Three additional databases can be enabled for optional features:

| Database | Default name | Feature |
|---|---|---|
| modelInferenceLogs | `model_logs` | LLM inference logging |
| promptHub | `prompt_hub` | Shared prompt library |
| auditLogs | `audit_logs` | Detailed audit trail |

## Minimum values.yaml

```yaml
semoss:
  social:
    redirectUrl: "https://my.example.org/SemossWeb/"

  environmentVariables:
    SEMOSS_STORAGE_PROVIDER: "S3"   # or AZURE / GCS / MINIO / LOCAL
    S3_REGION: "us-east-1"
    S3_BUCKET: "my-semoss-bucket"

ingress:
  hosts:
    - host: my.example.org
      paths:
        - /

security:
  connectionUrl: "jdbc:postgresql://db-host:5432/security?currentSchema=public"
  username: "semoss"
  password: "changeme"

localmaster:
  connectionUrl: "jdbc:postgresql://db-host:5432/localmaster?currentSchema=public"
  username: "semoss"
  password: "changeme"

scheduler:
  connectionUrl: "jdbc:postgresql://db-host:5432/scheduler?currentSchema=public"
  username: "semoss"
  password: "changeme"

themes:
  connectionUrl: "jdbc:postgresql://db-host:5432/themes?currentSchema=public"
  username: "semoss"
  password: "changeme"

usertracking:
  connectionUrl: "jdbc:postgresql://db-host:5432/user_tracking?currentSchema=public"
  username: "semoss"
  password: "changeme"
```

## Cluster Mode

Set `replicaCount > 1` and enable Zookeeper:

```yaml
semoss:
  replicaCount: 3

zookeeper:
  enabled: true
```

`ZK_SERVER` is automatically set to the in-cluster Zookeeper service when `zookeeper.enabled: true`.

## Image

```
quay.io/semoss/semoss:5.1.0-ubuntu22
```

Set `imagePullSecrets` to the name of a Kubernetes secret with quay.io credentials if your cluster requires it.
