# SEMOSS Helm Install

This helm package will install a scalable SEMOSS installation backed with a cloud storage provider

## Installation

```bash
git clone https://github.com/SEMOSS/SEMOSS_Helm.git
cd SEMOSS_Helm/semoss
helm install semoss .
```


## Confirguation

Edit the values.yaml to add options such as enabling ingress and adding the hostname

```yaml
ingress:
  name: "ingress"
  enabled: true
   hosts:
      - host: my.example.org
```

Additionally add the required storage keys for Azure Blob or S3

Azure Requirements: Azure Account Key, Acure Account Name, Azure Connection String
```yaml
semoss:
  environmentVariables:
    SEMOSS_STORAGE_PROVIDER: "AZURE"
    AZURE_ACCT_KEY: "aaaaaaaaabbbbbbbbbbccccccc"
    AZURE_ACCT_NAME: "myacct"
```

S3 Requirements: S3 Region and S3 bucket are required. If available, S3 access key and Secret Key can be provided otherwise it can be loaded through env vars or an IAM instance profile
```yaml
semoss:
  environmentVariables:
    SEMOSS_STORAGE_PROVIDER: "S3"
    S3_REGION: "us-east-1"
    S3_BUCKET: "mybucket"
    S3_ACCESS_KEY: "abcd"
    S3_SECRET_KEY: "1234"
```
