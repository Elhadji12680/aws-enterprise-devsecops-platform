variable "db_subnet_az_1a" {
  type = string
}
variable "db_subnet_az_1b" {
  type = string
}
variable "tags" {
  type = map(string)
}
variable "vpc_id" {
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
variable "rds_secrets_manager_role" {
  type = string
}