output "monitoring_namespace" {
  value = kubernetes_namespace.monitoring.metadata[0].name
}

output "prometheus_stack_status" {
  value = helm_release.kube_prometheus_stack.status
}
