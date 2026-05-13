variable "vpc_cidr_block" {
    type = string
}

variable "tags" {
    type = map(string)
  
}
variable "subnet_cidr_block" {
  type = list(string)
  
}
variable "availability_zone" {
  type = list(string)
}

