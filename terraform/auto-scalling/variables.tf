variable "vpc_id" {
  type = string
}
variable "tags" {
  type = map(string)
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
variable "public_subnet_az_1b_id" {
  type = string
  
}
variable "public_subnet_az_1a_id" {
  type = string
}
variable "jupiter_app_tg_arn" {
  type = list(string)
}
variable "desired_capacity" {
  type = number
}