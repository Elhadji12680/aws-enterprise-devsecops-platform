output "sonarqube_namespace" {
  value = kubernetes_namespace.sonarqube.metadata[0].name
}

output "sonarqube_helm_status" {
  value = helm_release.sonarqube.status
}
