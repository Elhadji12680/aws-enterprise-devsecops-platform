# MONITORING NAMESPACE ---------------------------------------------------------------
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# KUBE-PROMETHEUS-STACK ---------------------------------------------------------------
# Bundles: Prometheus, Grafana, AlertManager, Node Exporter, kube-state-metrics
resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.prometheus_stack_chart_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  timeout    = 600

  values = [
    yamlencode({
      grafana = {
        adminPassword = var.grafana_admin_password
        service = {
          type = "LoadBalancer"
          port = 80
        }
        persistence = {
          enabled      = true
          storageClass = "gp2"
          size         = "5Gi"
        }
        dashboardProviders = {
          "dashboardproviders.yaml" = {
            apiVersion = 1
            providers = [{
              name            = "default"
              orgId           = 1
              folder          = ""
              type            = "file"
              disableDeletion = false
              options = {
                path = "/var/lib/grafana/dashboards/default"
              }
            }]
          }
        }
        dashboards = {
          default = {
            kubernetes-cluster = {
              gnetId     = 7249
              revision   = 1
              datasource = "Prometheus"
            }
            node-exporter = {
              gnetId     = 1860
              revision   = 37
              datasource = "Prometheus"
            }
            trivy-operator = {
              gnetId     = 17813
              revision   = 2
              datasource = "Prometheus"
            }
          }
        }
      }

      prometheus = {
        prometheusSpec = {
          retention           = "15d"
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "gp2"
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "20Gi"
                  }
                }
              }
            }
          }
        }
      }

      alertmanager = {
        alertmanagerSpec = {
          storage = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "gp2"
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "2Gi"
                  }
                }
              }
            }
          }
        }
      }

      nodeExporter = {
        enabled = true
      }

      kubeStateMetrics = {
        enabled = true
      }
    })
  ]

  depends_on = [kubernetes_namespace.monitoring]
}
