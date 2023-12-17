<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.grafana_agent](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_blackbox_targets"></a> [blackbox\_targets](#input\_blackbox\_targets) | n/a | <pre>list(object({<br>    name = string<br>    url  = string<br>  }))</pre> | `[]` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_cluster_namespace"></a> [cluster\_namespace](#input\_cluster\_namespace) | n/a | `string` | n/a | yes |
| <a name="input_loki_enabled"></a> [loki\_enabled](#input\_loki\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_loki_pass"></a> [loki\_pass](#input\_loki\_pass) | n/a | `string` | `null` | no |
| <a name="input_loki_url"></a> [loki\_url](#input\_loki\_url) | n/a | `string` | `null` | no |
| <a name="input_loki_user"></a> [loki\_user](#input\_loki\_user) | n/a | `string` | `null` | no |
| <a name="input_mode"></a> [mode](#input\_mode) | n/a | `string` | n/a | yes |
| <a name="input_prometheus_enabled"></a> [prometheus\_enabled](#input\_prometheus\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_prometheus_labels_filter"></a> [prometheus\_labels\_filter](#input\_prometheus\_labels\_filter) | n/a | `string` | `null` | no |
| <a name="input_prometheus_metrics_filter"></a> [prometheus\_metrics\_filter](#input\_prometheus\_metrics\_filter) | n/a | `string` | `null` | no |
| <a name="input_prometheus_pass"></a> [prometheus\_pass](#input\_prometheus\_pass) | n/a | `string` | `null` | no |
| <a name="input_prometheus_url"></a> [prometheus\_url](#input\_prometheus\_url) | n/a | `string` | `null` | no |
| <a name="input_prometheus_user"></a> [prometheus\_user](#input\_prometheus\_user) | n/a | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->