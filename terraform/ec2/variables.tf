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
variable "public_subnet_az_1a_id" {
  type = string
}
variable "key_name" {
  type = string
}
variable "ec2_instance_profile_name" {
  type = string
}
