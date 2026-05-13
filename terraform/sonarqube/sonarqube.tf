# SONARQUBE NAMESPACE ---------------------------------------------------------------
resource "kubernetes_namespace" "sonarqube" {
  metadata {
    name = "sonarqube"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# SONARQUBE HELM RELEASE ---------------------------------------------------------------
resource "helm_release" "sonarqube" {
  name       = "sonarqube"
  repository = "https://SonarSource.github.io/helm-chart-sonarqube"
  chart      = "sonarqube"
  version    = var.sonarqube_chart_version
  namespace  = kubernetes_namespace.sonarqube.metadata[0].name
  timeout    = 600

  values = [
    yamlencode({
      service = {
        type = "LoadBalancer"
        port = 9000
      }
      persistence = {
        enabled      = true
        storageClass = "gp2"
        size         = "10Gi"
      }
      resources = {
        requests = {
          cpu    = "500m"
          memory = "1Gi"
        }
        limits = {
          cpu    = "1000m"
          memory = "2Gi"
        }
      }
      jdbcOverwrite = {
        enable = false
      }
      postgresql = {
        enabled = true
        persistence = {
          enabled = true
          size    = "5Gi"
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.sonarqube]
}
