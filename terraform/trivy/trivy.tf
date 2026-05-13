# TRIVY NAMESPACE ---------------------------------------------------------------
resource "kubernetes_namespace" "trivy_system" {
  metadata {
    name = "trivy-system"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# TRIVY OPERATOR ---------------------------------------------------------------
# Continuously scans all workloads on the cluster for CVEs and misconfigurations
resource "helm_release" "trivy_operator" {
  name       = "trivy-operator"
  repository = "https://aquasecurity.github.io/helm-charts/"
  chart      = "trivy-operator"
  version    = var.trivy_chart_version
  namespace  = kubernetes_namespace.trivy_system.metadata[0].name

  values = [
    yamlencode({
      trivy = {
        ignoreUnfixed = true
      }
      operator = {
        scanJobTimeout = "5m"
        vulnerabilityScanner = {
          enabled = true
        }
        configAuditScanner = {
          enabled = true
        }
        rbacAssessmentScanner = {
          enabled = true
        }
        infraAssessmentScanner = {
          enabled = true
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.trivy_system]
}
