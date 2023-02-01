
variable "instance_type" {
  default = "t2.micro"
  type        = string
}
variable "env" {
  default = "dev"
}
variable subnets {
  description = "Subnet IDs for EC2 instances"
  type        = list(string)
}
variable "vpc"{
type        = string
default = ""
}
variable "allow_ports" {
  type    = list(any)
  default = ["80", "443", "22", "8080"]
}