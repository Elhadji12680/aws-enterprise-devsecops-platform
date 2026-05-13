variable "prometheus_stack_chart_version" {
  type = string
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
}
