variable "vpc_cidr_block" {
  type = string
}

variable "subnet_cidr_block" {
  type = list(string)

}
variable "availability_zone" {
  type = list(string)
}
variable "ami" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "key_name" {
  type = string
}

variable "max_size" {
  type = number
}
variable "min_size" {
  type = number
}
variable "desired_capacity" {
  type = number
}
variable "ssl_policy" {
  type = string
}
variable "certificate_arn" {
  type = string
}
variable "route53_zone_id" {
  type = string
}
variable "name" {
  type = string
}

variable "allocated_storage" {
  type = number
}
variable "db_name" {
  type = string
}
variable "engine" {
  type = string
}
variable "engine_version" {
  type = string
}
variable "instance_class" {
  type = string
}
variable "parameter_group_name" {
  type = string

}

variable "region" {
  type = string
}
variable "account_id" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "node_instance_type" {
  type = string
}

variable "node_desired_size" {
  type = number
}

variable "node_min_size" {
  type = number
}

variable "node_max_size" {
  type = number
}

variable "argocd_chart_version" {
  type = string
}

variable "argocd_git_repo_url" {
  type = string
}

variable "argocd_git_repo_branch" {
  type = string
}

variable "trivy_chart_version" {
  type = string
}

variable "sonarqube_chart_version" {
  type = string
}

variable "prometheus_stack_chart_version" {
  type = string
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
}