locals {
  node_values = {
    crds = {
      create = false
    }
    agent = {
      mode = "static"
      configMap = {
        create : true
      }
      mounts = {
        dockercontainers = true
        varlog           = true
        extra = [
          { name      = "rootfs"
            mountPath = "/host/root"
          },
          { name      = "sysfs"
            mountPath = "/host/sys"
          },
          { name      = "procfs"
            mountPath = "/host/proc"
          },
        ]
      }
    }
    controller = {
      volumes = {
        extra = [
          { name = "rootfs"
            hostPath = {
              path = "/root"
            }
          },
          { name = "sysfs"
            hostPath = {
              path = "/sys"
            }
          },
          { name = "procfs"
            hostPath = {
              path = "/proc"
            }
          }
        ]
      }
      type = "daemonset"
      securityContext = {
        privileged = true
        runAsUser  = 0
      }
    }
  }

  cluster_values = {
    crds = {
      create = false
      controller = {
        type = "deployment"
      }
      agent = {
        mode = "static'"
        configMap = {
          create = true
        }
        securityContext = {
          privileged = true
          runAsUser  = 0
        }
        extraArgs = [
          "-enable-features=integrations-next"
        ]
      }
    }
  }
}

resource "helm_release" "grafana_agent" {
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana-agent"
  name       = "${var.mode}-agent"
  namespace  = var.cluster_namespace
  version    = "0.29.0"

  set {
    name = "agent.configMap.content"
    value = templatefile("${path.module}/templates/${var.mode}_grafana_agent.tpl", {
      prometheus_enabled         = var.prometheus_enabled
      prometheus_pass            = var.prometheus_pass
      prometheus_user            = var.prometheus_user
      prometheus_url             = var.prometheus_url
      prometheus_metrics_filter  = var.prometheus_metrics_filter
      prometheus_labels_filter   = var.prometheus_labels_filter
      prometheus_scrape_interval = "1m"
      loki_enabled               = var.loki_enabled
      loki_url                   = var.loki_url
      loki_user                  = var.loki_user
      loki_pass                  = var.loki_pass
      cluster_name               = "${var.cluster_name}"
      blackbox_targets           = var.blackbox_targets
    })
  }

  values  = [var.mode == "node" ? yamlencode(local.node_values) : yamlencode(local.cluster_values)]
  timeout = 900
}