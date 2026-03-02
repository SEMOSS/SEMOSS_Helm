# SEMOSS Helm Chart

Helm chart for deploying SEMOSS on Kubernetes with external PostgreSQL system databases and cloud object storage.

## Requirements

- Kubernetes 1.21+
- Helm 3.x
- nginx ingress controller
- External PostgreSQL instance (5 system databases required)
- Cloud storage provider (Azure Blob, S3, GCS, or MinIO) — or `LOCAL` for single-node

## Quick Start

```bash
git clone https://github.com/SEMOSS/SEMOSS_Helm.git
cd SEMOSS_Helm/semoss
# edit values.yaml with your settings
helm install semoss . -f values.yaml
```

## Chart Contents

| Template | Description |
|---|---|
| `semoss-deployment.yaml` | Main SEMOSS application pod |
| `semoss-service.yaml` | ClusterIP service on port 8080 |
| `ingress.yaml` | nginx ingress with sticky-session cookie affinity |
| `zk-deployment.yaml` | Zookeeper pod (disabled by default) |
| `zk-service.yaml` | Zookeeper ClusterIP service on port 2181 |

## Configuration

### 1. Image

```yaml
semoss:
  image:
    repository: quay.io/semoss/semoss
    tag: "5.1.0-ubuntu22"
    pullPolicy: Always
```

For private registry access set `imagePullSecrets` to the name of your pull secret:

```yaml
imagePullSecrets: "quay-pull-secret"
```

### 2. System Databases (required)

All five databases must exist in PostgreSQL before install. Provide a full JDBC connection URL and credentials for each:

```yaml
security:
  connectionUrl: "jdbc:postgresql://<host>:5432/security?currentSchema=public"
  username: "semoss"
  password: "changeme"

localmaster:
  connectionUrl: "jdbc:postgresql://<host>:5432/localmaster?currentSchema=public"
  username: "semoss"
  password: "changeme"

scheduler:
  connectionUrl: "jdbc:postgresql://<host>:5432/scheduler?currentSchema=public"
  username: "semoss"
  password: "changeme"

themes:
  connectionUrl: "jdbc:postgresql://<host>:5432/themes?currentSchema=public"
  username: "semoss"
  password: "changeme"

usertracking:
  enabled: true
  connectionUrl: "jdbc:postgresql://<host>:5432/user_tracking?currentSchema=public"
  username: "semoss"
  password: "changeme"
```

### 3. Optional Feature Databases

Enable additional databases to activate optional features:

```yaml
modelInferenceLogs:
  enabled: true
  connectionUrl: "jdbc:postgresql://<host>:5432/model_logs?currentSchema=public"
  username: "semoss"
  password: "changeme"

promptHub:
  enabled: true
  connectionUrl: "jdbc:postgresql://<host>:5432/prompt_hub?currentSchema=public"
  username: "semoss"
  password: "changeme"

auditLogs:
  enabled: true
  connectionUrl: "jdbc:postgresql://<host>:5432/audit_logs?currentSchema=public"
  username: "semoss"
  password: "changeme"
```

### 4. Cloud Storage

Set `SEMOSS_STORAGE_PROVIDER` and the corresponding credentials:

**Azure Blob Storage:**
```yaml
semoss:
  environmentVariables:
    SEMOSS_STORAGE_PROVIDER: "AZURE"
    AZCONN: "DefaultEndpointsProtocol=https;AccountName=...;AccountKey=...;EndpointSuffix=core.windows.net"
    AZ_NAME: "mystorageaccount"
    AZ_KEY: "base64key=="
```

**AWS S3:**
```yaml
semoss:
  environmentVariables:
    SEMOSS_STORAGE_PROVIDER: "S3"
    S3_REGION: "us-east-1"
    S3_BUCKET: "my-semoss-bucket"
    S3_ACCESS_KEY: ""   # leave blank when using IRSA / instance role
    S3_SECRET_KEY: ""
```

For IRSA (AWS EKS), leave `S3_ACCESS_KEY`/`S3_SECRET_KEY` empty and set the service account:
```yaml
semoss:
  serviceAccount:
    name: "semoss-sa"   # annotated with eks.amazonaws.com/role-arn
```

**GCS:**
```yaml
semoss:
  environmentVariables:
    SEMOSS_STORAGE_PROVIDER: "GCS"
```

### 5. Ingress

```yaml
ingress:
  enabled: true
  hosts:
    - host: my.example.org
      paths:
        - /
  tls:
    - hosts:
        - my.example.org
      secretName: semoss-tls
```

The ingress ships with nginx sticky-session cookie affinity (`route-semoss`) and 48-hour session expiry configured by default.

### 6. Cluster Mode (Horizontal Scaling)

For multiple SEMOSS replicas, enable Zookeeper:

```yaml
semoss:
  replicaCount: 3

zookeeper:
  enabled: true   # deploys ZK pod and auto-sets ZK_SERVER env var
```

To use an external Zookeeper instead:

```yaml
zookeeper:
  enabled: false

semoss:
  environmentVariables:
    ZK_SERVER: "my-zookeeper-host:2181"
```

### 7. SSO / Social Login

Native login is enabled by default. To add SSO:

**Microsoft Entra ID (Azure AD):**
```yaml
semoss:
  social:
    enable_ms_login: "true"
    ms_authority: "https://login.microsoftonline.com/<tenant>/"
    ms_tenant: "<tenant-id>"
    ms_client_id: "<client-id>"
    ms_secret_key: "<client-secret>"
    ms_redirect_uri: "https://my.example.org/Monolith/api/auth/social/ms"
```

**Google:**
```yaml
semoss:
  social:
    enable_google_login: "true"
    google_client_id: "<client-id>"
    google_secret_key: "<client-secret>"
    google_redirect_uri: "https://my.example.org/Monolith/api/auth/social/google"
```

**GitHub:**
```yaml
semoss:
  social:
    enable_github_login: "true"
    github_client_id: "<client-id>"
    github_secret_key: "<client-secret>"
    github_redirect_uri: "https://my.example.org/Monolith/api/auth/social/github"
```

### 8. Resources

Default resource requests and limits:

```yaml
semoss:
  resources:
    limits:
      cpu: "8"
      memory: "30Gi"
    requests:
      cpu: "2"
      memory: "8Gi"
```

## Upgrade

```bash
helm upgrade semoss . -f values.yaml
```

> **Note:** The deployment uses `strategy: Recreate`. Pods are terminated before new ones start to prevent split-brain on shared storage.

## Uninstall

```bash
helm uninstall semoss
```
