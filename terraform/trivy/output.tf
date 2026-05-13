output "trivy_namespace" {
  value = kubernetes_namespace.trivy_system.metadata[0].name
}

output "trivy_operator_status" {
  value = helm_release.trivy_operator.status
}
