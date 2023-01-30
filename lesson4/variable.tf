variable "vpc_cidr" {
  description = "CIDR Block for VPC"
  type        = string
}
variable "instance_type" {
  default = "t2.micro"
  type        = string
}
variable "attach_target_group" {
  default = true
}
variable "target_group_count" {}
# variable "instance_ids" {
#   type = list(string)
# }
