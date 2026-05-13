# ARGOCD NAMESPACE ---------------------------------------------------------------
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# ARGOCD HELM RELEASE ---------------------------------------------------------------
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  # Disable TLS on the server — add ingress + cert-manager in prod
  values = [
    yamlencode({
      server = {
        service = {
          type = "LoadBalancer"
        }
        rbacConfig = {
          "policy.default" = "role:readonly"
        }
      }
      configs = {
        params = {
          "server.insecure" = true
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

# JUPITER APP NAMESPACE ---------------------------------------------------------------
resource "kubernetes_namespace" "jupiter" {
  metadata {
    name = "jupiter"
    labels = {
      "app.kubernetes.io/managed-by" = "argocd"
    }
  }

  depends_on = [helm_release.argocd]
}

# ARGOCD APPLICATION (GitOps) ---------------------------------------------------------------
# Syncs k8s/jupiter/ manifests from the Git repo onto the cluster automatically
resource "kubernetes_manifest" "jupiter_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "jupiter-app"
      namespace = "argocd"
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.argocd_git_repo_url
        targetRevision = var.argocd_git_repo_branch
        path           = "k8s"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "jupiter"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = ["CreateNamespace=true"]
      }
    }
  }

  depends_on = [helm_release.argocd, kubernetes_namespace.jupiter]
}
