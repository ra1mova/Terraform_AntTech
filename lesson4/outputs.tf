output "remote_state" {
    value = data.terraform_remote_state.network.outputs
}
output "subnet_id" {
    value = {for i, q in aws_subnet.public_subnets : i => q.id}
}
# output "vpc_id" {
#   value = aws_vpc.vpc.id
# }