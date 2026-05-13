variable "vpc_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "private_subnet_az_1a_id" {
  type = string
}

variable "private_subnet_az_1b_id" {
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
