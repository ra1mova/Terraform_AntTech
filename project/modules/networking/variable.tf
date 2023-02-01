variable "public_subnet_cidrs" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
}
variable "env" {
  default = "env"
   type   = string
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
   type        = string
}
