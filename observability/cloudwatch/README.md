# CloudWatch — AWS Observability

CloudWatch provides centralized log aggregation and monitoring for AWS infrastructure and workloads in this platform. Log groups capture control-plane events from EKS and general-purpose compute, forming the foundation for AWS-native operational visibility.

## Role in the Observability Stack

- **Infrastructure Logging** — Collects control-plane logs from EKS API server, audit, authenticator, controller-manager, and scheduler components.
- **Compute Logging** — Captures system and application logs from EC2 instances, EKS nodes, and other AWS compute.
- **Operational Intelligence** — Supports log search, metric extraction, and alarm creation via CloudWatch Logs Insights and CloudWatch Metrics.

## AWS Resources

### Log Groups

Log groups are provisioned via Terraform in `infrastructure/terraform/modules/cloudwatch/main.tf`. Two log groups are created for the reference environment:

| Log Group Name | Retention | Purpose                              |
|----------------|-----------|--------------------------------------|
| `/aws/devops-vm` | 7 days  | General-purpose compute, VMs, and devops workloads |
| `/aws/k8s-vm`    | 7 days  | Kubernetes control-plane and node logs |

Retention is set to **7 days**. Modify `retention_in_days` in the Terraform module to extend or shorten the retention period.

## Enabled Log Types

The following EKS control-plane log types are intended to be enabled on the EKS cluster (requires EKS cluster configuration, not managed in this module):

| Log Type            | Description                                              |
|---------------------|----------------------------------------------------------|
| `api`               | API server audit log — every authenticated API request   |
| `audit`             | Extended audit metadata including request metadata       |
| `authenticator`     | IAM authenticator for RBAC decisions                     |
| `controllerManager` | Controller-manager reconciliation operations             |
| `scheduler`         | Kubernetes scheduler decisions and pod placement         |

## Data Flow

```
EKS Cluster (control plane)  ──(CloudWatch Logs)──>  /aws/k8s-vm
EC2 / EKS Nodes              ──(CloudWatch Agent)──>  /aws/devops-vm
                                                            |
                                                            v
                                                   CloudWatch Logs Insights
                                                   CloudWatch Metrics / Alarms
```

### Shipping Container Logs

For containerised workloads running on EKS, the [CloudWatch Agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights.html) (or Fluent Bit) must be deployed as a DaemonSet in the cluster to forward container stdout/stderr to the appropriate log group.

## Terraform Module Usage

```hcl
module "cloudwatch" {
  source = "./modules/cloudwatch"
}
```

### Outputs

| Output          | Description                    |
|-----------------|--------------------------------|
| `devops_log_group` | Name of `/aws/devops-vm` log group |

## Integrating with the Observability Stack

CloudWatch is the AWS-native observability layer and complements the self-hosted ELK stack:

| Scenario                      | Tool            |
|-------------------------------|-----------------|
| AWS control-plane audit       | CloudWatch      |
| Kubernetes workload logs      | CloudWatch Agent → CloudWatch or Fluent Bit → ELK |
| Host-level metrics and logs   | CloudWatch Agent → CloudWatch |
| Centralised search across all | ELK (via Fluent Bit or Beats forwarding CloudWatch logs) |

To forward CloudWatch log groups into the self-hosted ELK stack, use [Fluent Bit](https://aws.amazon.com/blogs/containers/forwarding-cloudwatch-logs-to-amazon-elasticsearch-using-fluent-bit/) or the [CloudWatch Logs subscription filter](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/SubscriptionFilter.html).

## Retention Policy

Log retention is **7 days** for all log groups in the reference configuration. To change:

```hcl
# In infrastructure/terraform/modules/cloudwatch/main.tf
resource "aws_cloudwatch_log_group" "devops" {
  name              = "/aws/devops-vm"
  retention_in_days = 30   # extend to 30 days
}
```

## Accessing Logs

### AWS Console

1. Open the CloudWatch console at `https://console.aws.amazon.com/cloudwatch`.
2. Select **Logs** → **Log groups**.
3. Select the relevant log group and use **Logs Insights** for interactive querying.

### AWS CLI

```bash
# List log groups
aws logs describe-log-groups --log-group-name-prefix /aws/devops-vm

# Query log streams
aws logs describe-log-streams \
  --log-group-name /aws/devops-vm \
  --order-by LastEventTime \
  --descending \
  --limit 5

# Fetch recent log events
aws logs filter-log-events \
  --log-group-name /aws/k8s-vm \
  --start-time $(date -d '1 hour ago' +%s000)
```

## Alerts and Metrics

Create CloudWatch alarms on log group metric filters to alert on error patterns:

```bash
# Example: alarm on "ERROR" in /aws/devops-vm
aws cloudwatch put-metric-filter \
  --log-group-name /aws/devops-vm \
  --filter-name error-count \
  --metric-transformations metricName=ErrorCount,metricNamespace=DevOps,metricValue=1 \
  --filter-pattern "ERROR"
```

## Maintainer

**Hari Krishna Polavarapu**

- GitHub: https://github.com/HariPolavarapu
- LinkedIn: https://linkedin.com/in/hari-krishna-polavarapu